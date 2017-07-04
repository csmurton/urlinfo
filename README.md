# URL Info

A REST API providing a simple method to advise upstream clients (i.e. proxies) whether a URL is known to be malicious.

## Prerequisites

This code is intended to be deployed within AWS to leverage API Gateway, ElastiCache and Lambda but can also be run inside a Docker container or as a standalone webserver under NodeJS 4.2.6+. You will also need a Git client installed on your system.

To deploy within AWS you should first download Terraform v0.9.4 or later: https://www.terraform.io/downloads.html

To simplify the deployment process into AWS with Terraform all of the required NodeJS modules are distributed with this repository in `node/node_modules`.


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

 * Discover the AWS default VPC in the account and region you run it in (defaults to eu-west-1)
 * Create a subnet in a random availability zone in the AWS default VPC
 * Create a NAT Gateway to allow the demonstration URL Blacklist import route to function in the default subnet in the same AZ as the custom subnet
 * Create a VPC security group for communication between the Lambda function and the Redis ElastiCache cluster
 * Create an ElastiCache subnet group incorporating the newly created subnet in the discovered default VPC
 * Create a Redis ElastiCache cluster node
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

Part of the Terraform provisioning process is to cause the API to seed the Redis backend with around ~3,000 'bad' URLs via a 3rd party blacklist.

Once completed you should be presented with the API Gateway invocation path which takes the form https://xxxxxxxxxx.execute-api.eu-west-1.amazonaws.com/dev. Suffix this with /urlinfo/1/XXXX to reach the API routes, i.e:

https://xxxxxxxxxx.execute-api.eu-west-1.amazonaws.com/dev/urlinfo/1/www.badsite.com:80/badpath

### Docker

From the root of the repository, run the following commands to build and then start the service in a container running on localhost:5000:

```
docker build -t csmurton/urlinfo:latest .
docker run -p 127.0.0.1:5000:5000 csmurton/urlinfo:latest
```

If desired you should now seed the Redis server running in the container with sample data by browsing to http://localhost:5000/urlloader. Note: Your client should have unrestricted outbound port 80 access for this to succeed.

## Configuration

URL Info is configured by the use of environment variables:

| Variable                 | Purpose                                                                            | Default   |
| ------------------------ | ---------------------------------------------------------------------------------- | --------- |
| DATABASE_CONNECT_TIMEOUT | The amount of time (in milliseconds) to wait for a connection to the backend.      | 3000      |
| DATABASE_HOST            | The hostname or IP address of the database backend.                                | localhost |
| DATABASE_REQUEST_TIMEOUT | The amount of time (in milliseconds) to wait for a database request to complete.	| 10000     |
| DATABASE_PORT            | The port number on which the database backend is listening.                        | 6379      |
| DATABASE_PROVIDER        | Sets the backend database provider. Currently only 'redis' is supported.           | redis     |
| LISTEN_PORT              | If running in standalone mode, this is the port the API will listen on.            | 5000      |
| LOGGING_LOGLEVEL         | The verbosity of the logging printed to the console.                               | debug     |


## Testing

Unit testing for functionality that doesn't require a database backend to be present has been included using the Mocha framework. To run these tests, from your 'urlinfo' directory:
```
cd node/
npm install && npm test
```

## Known limitations

 * The only database provider currently supported is Redis but most backends that support CRUD operations should be suitable.
 * A simple, functional API route and piece of code to load sample data into the Redis backend has been included. In production this would be handled separately and/or improved to stream the blacklist entries to Redis thereby reducing memory footprint during the loading exercise.
 * AWS API Gateway has an integration timeout of 30 seconds that cannot be customised. All requests must be completed within that time to avoid receiving HTTP 5xx errors.
 * The unit tests do not check for the presence/absence of particular URLs because there is no guarantee the database backend is present.
 * The host portion of the request URL is deliberately lowercased for tokenisation but the path is not, as most *nix based webservers expect path to be case sensitive.

