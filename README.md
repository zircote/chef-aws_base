Description
===========
Maintains the Route53 hostname provisioning for AWS instances.

Requirements
============
n/a
Attributes
==========

```ruby

default[:aws_base][:zone] = "aws.myzone.com"
default[:aws_base][:data_bag][:route53][:name] = "aws"
default[:aws_base][:data_bag][:route53][:item] = "route53
default[:aws_base][:data_bag][:ec2][:name] = "aws"
default[:aws_base][:data_bag][:ec2][:item] = "ro"

```

Usage
=====

Databag storage of AWS Credentials should reside in the following keys:

 - `aws_access_key_id`
 - `aws_secret_access_key`

```json
{
    "aws_base":{
        "zone":"aws.myzone.com",
        "data_bag":{
            "route53":{
            "name":"aws",
            "item":"route53"
            },
            "ec2":{
            "name":"aws",
            "item":"ro"
            }
        }
    }
}

```
