# URL Info

A REST API providing a simple method to advise upstream clients (i.e. proxies) whether a URL is known to be malicious.

## Prerequisites

This code is intended to be deployed within AWS to leverage API Gateway, ElastiCache and Lambda but can also be run as a standalone webserver under Node 6.10+. You will also need a Git client installed on your system.

To deploy within AWS you should first download Terraform v0.9.4 or later: [https://www.terraform.io/downloads.html]

## Getting started

You'll first need to clone the repository and change into it:
```
git clone https://github.com/csmurton/urlinfo.git
cd urlinfo
```

### AWS

If you would like to proceed with the recommended approach of deploying this service in AWS, you will need an Amazon Web Services account and an IAM user defined with an API key.

If you haven't yet downloaded Terraform v0.9.4 or later then please do so and extract the binary from the ZIP file anywhere within your PATH.
The recommended approach is to first download Terraform as above. 

The Terraform scripts included in this repository will:

 * Discover the AWS default VPC and subnets in the account and region you run it in (defaults to eu-west-1)
 * Create a VPC security group for communication between the Lambda function and the Redis ElastiCache cluster
 * Create an ElastiCache subnet group incorporating each subnet in the discovered default VPC
 * Create a Redis ElastiCache cluster defaulting to a single node
 * Create an IAM role for the Lambda function to run under
 * Create a Lambda function by zipping and deploying all code in the ../node path
 * Create an IAM role for API Gateway to use for invoking the Lambda function
 * Create API Gateway methods, invocations and a 'dev' stage
 * Create an IAM role for Cloudwatch Events to use for invoking the Lambda function
 * Create a Cloudwatch Events rule and target to poll the Lambda function at regular intervals

A list of the variables that can be customised is kept in 'variables.tf'.

If you are happy with the provided defaults and options, run:
```
terraform apply -var 'aws_profile=<name-of-your-profile-defined-in-.aws-credentials>'
```

Alternatively if you wish to make customisations such as the region:
```
terraform apply -var 'aws_profile=<name-of-your-profile-defined-in-.aws-credentials>' -var 'aws_region=us-east-1'
```

Once completed you should be presented with the API Gateway invocation path which takes the form [https://xxxxxxxxxx.execute-api.eu-west-1.amazonaws.com/dev].

### Standalone

You should download and install NodeJS 6.10+ and optionally Redis 3.2+ ([https://redis.io/download]) to run a local in-memory database to hold the URL information.

URL Info is configured by the use of environment variables:

| Variable          | Purpose                                                                  | Default   |
| ----------------- | ------------------------------------------------------------------------ | --------- |
| DATABASE_HOST     | The hostname or IP address of the database backend.                      | localhost |
| DATABASE_PORT     | The port number on which the database backend is listening.              | 6379      |
| DATABASE_PROVIDER | Sets the backend database provider. Currently only 'redis' is supported. | redis     |
| LISTEN_PORT       | If running in standalone mode, this is the port the API will listen on.  | 5000      |

TODO.
