import pathlib
import socket
from awscrt import io, mqtt
from awsiot import mqtt_connection_builder
import sys
import threading
import requests
from uuid import uuid4
import json

certificate_dir = '/home/pi/certs'
root_cert = f"{certificate_dir}/Amazon-root-CA-1.pem"
certificate = f"{certificate_dir}/device.pem.crt"
private_key = f"{certificate_dir}/private.pem.key"
bucket_name = "motion-detection-bucket"
endpoint_url = "ai6lmrf5duzrr-ats.iot.eu-central-1.amazonaws.com"
common_request_url_topic_name = "url_topic"
obtain_url_topic_name = "rpi3_topic"


received_all_event = threading.Event()
s3_signed_url = {}


class MQTTConnector:
    def __init__(self):
        self.connection = self.get_mqtt_connection()

    def subscribe_to_topic(self, topic):
        print(f"Subscribing to topic '{topic}'...")
        subscribe_future, packet_id = self.connection.subscribe(
            topic=topic,
            qos=mqtt.QoS.AT_LEAST_ONCE,
            callback=self.on_message_received)
        subscribe_result = subscribe_future.result()
        print(f"Subscribed with {subscribe_result['qos']}")

    def get_mqtt_connection(self):
        event_loop_group = io.EventLoopGroup(1)
        host_resolver = io.DefaultHostResolver(event_loop_group)
        client_bootstrap = io.ClientBootstrap(event_loop_group, host_resolver)
        client_id = f"{socket.gethostname()}-{uuid4()}"
        mqtt_connection = mqtt_connection_builder.mtls_from_path(
            endpoint=endpoint_url,
            cert_filepath=certificate,
            pri_key_filepath=private_key,
            client_bootstrap=client_bootstrap,
            ca_filepath=root_cert,
            on_connection_interrupted=self.on_connection_interrupted,
            on_connection_resumed=self.on_connection_resumed,
            client_id=client_id,
            clean_session=False,
            keep_alive_secs=30,
            http_proxy_options=None)
        print(f"Connecting to {endpoint_url} with client ID '{client_id}'...")

        connect_future = mqtt_connection.connect()

        # Future.result() waits until a result is available
        connect_future.result()
        print("Connected!")
        return mqtt_connection

    @staticmethod
    def on_connection_interrupted(connection, error, **kwargs):
        print(f"Connection interrupted. error: {error}")

    # Callback when an interrupted connection is re-established.
    @classmethod
    def on_connection_resumed(cls,connection, return_code, session_present, **kwargs):
        print(f"Connection resumed. return_code: {return_code} session_present: {session_present}")

        if return_code == mqtt.ConnectReturnCode.ACCEPTED and not session_present:
            print("Session did not persist. Resubscribing to existing topics...")
            resubscribe_future, _ = connection.resubscribe_existing_topics()

            # Cannot synchronously wait for resubscribe result because we're on the connection's event-loop thread,
            # evaluate result with a callback instead.
            resubscribe_future.add_done_callback(cls.on_resubscribe_complete)

    # Callback when the subscribed topic receives a message
    def on_message_received(self, topic, payload, dup, qos, retain, **kwargs):
        print(f"Received message from topic '{topic}': {payload}")
        if topic == obtain_url_topic_name:
            received_all_event.set()
            print("received_all_event is now set")
            global s3_signed_url
            s3_signed_url = json.loads(payload)

    @staticmethod
    def on_resubscribe_complete(resubscribe_future):
        resubscribe_results = resubscribe_future.result()
        print("Resubscribe results: {}".format(resubscribe_results))

        for topic, qos in resubscribe_results['topics']:
            if qos is None:
                sys.exit(f"Server rejected resubscribe to topic: {topic}")


class SignedURLMQTT(MQTTConnector):
    def demand_signed_url(self, mqtt_topc_name, basename):
        message = {"bucket_name": bucket_name,
                   "filename": basename,
                   "topic_to_post": obtain_url_topic_name}
        print(f"Publishing message to topic '{mqtt_topc_name}': {message}")
        message_json = json.dumps(message)
        self.connection.publish(
            topic=mqtt_topc_name,
            payload=message_json,
            qos=mqtt.QoS.AT_LEAST_ONCE)


def request_signed_url(mqtt_topic_name, basename):
    mqtt_connect = SignedURLMQTT()
    mqtt_connect.subscribe_to_topic(obtain_url_topic_name)
    mqtt_connect.subscribe_to_topic(mqtt_topic_name)
    mqtt_connect.demand_signed_url(mqtt_topic_name, basename)
    received_all_event.wait()


def send_file_using_signed_url(object_path):
    with open(object_path, 'rb') as f:
        files = {'file': (object_path, f)}
        print(s3_signed_url)
        http_response = requests.post(s3_signed_url['url'], data=s3_signed_url['fields'], files=files)
    print(f'File upload HTTP status code: {http_response}')


if __name__ == "__main__":
    file_name = pathlib.Path(sys.argv[-1]).name
    request_signed_url(common_request_url_topic_name, file_name)
    send_file_using_signed_url(sys.argv[-1])

