# IoT Ingest Large-Sized Payloads

Securely ingest large sized payloads from IoT devices using AWS.

## Description

This project is mainly based on this [AWS Blog](https://aws.amazon.com/blogs/iot/securely-ingesting-large-sized-payloads-from-iot-devices-to-the-aws-cloud/) which leverages the power of S3 pre-signed URLs, MQTT and IoT Core to upload large files.
Once the object is uploaded, the S3 Notification triggers a Lambda which sends an email to view the file.

![alt text](https://d2908q01vomqb2.cloudfront.net/f6e1126cedebf23e1463aee73f9df08783640400/2021/08/20/AWS-IoT-Blog_V2.jpg)

## Getting Started

### Dependencies

* An AWS Account
  * Generate the [certificate](https://docs.aws.amazon.com/iot/latest/developerguide/device-certs-create.html) needed to authenticate the IoT device(s). The following are needed:
    * Amazon Root CA certificate file (Amazon-root-CA-1.pem)
    * Private key file (private.pem.key)
    * A certificate for this thing (device.pem.crt)
  * Obtain the device-data-endpoint. Looks similar to `account-specific-prefix.jobs.iot.aws-region.amazonaws.com`.
  * Register your [email address](https://docs.aws.amazon.com/ses/latest/DeveloperGuide/verify-addresses-and-domains.html) for the SES to be able to send emails.
* An IoT device (eg. a Raspberry Pi).
* [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)

### Terraform setup

* Clone this repository on the laptop/desktop/server
```
git clone https://github.com/vikramaditya91/iot-ingest-large-size.git
```
* Get the ARN of the certificate and set it in the `terraform/variables.tf`
* Adjust other variables in `terraform/variables.tf` as required
* Apply the terraform configuration:
```
cd terraform
terraform apply
```

### Set-up on IoT device

* Copy the certificates onto the IoT device
* Clone this repository on the IoT device
```
git clone https://github.com/vikramaditya91/iot-ingest-large-size.git
```
* Create a virtual environment of Python3+
* Install the dependencies listed in pip_requirements.txt
* Set the correct values in `send_large_file.py`
  * paths to the certificates
  * bucket-name as set in `variables.tf`
  * end-point url as obtained above
  * request url topic as set in `variables.tf`
* Run the script `python send_large_file.py <full_path_to_file_to_be_uploaded>`


## Additional information

* This project was originally meant for a motion detection system for when my cat Doudou wanted to be let in
![Dudu cat](https://i.ibb.co/HtcgdWN/Whats-App-Image-2021-12-20-at-11-18-42-PM.jpg)
* Motion was detected using the [Motion Project](https://motion-project.github.io/)



## Authors

[Vikramaditya Gaonkar](https://github.com/vikramaditya91)
