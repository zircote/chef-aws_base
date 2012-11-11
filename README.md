Description
===========
Maintains the Route53 hostname provisioning for AWS instances.

Requirements
============
n/a
Attributes
==========

```ruby
default[:aws_base][:zone] = nil
default[:aws_base][:data_bag][:name] = "aws"
default[:aws_base][:data_bag][:item] = "readonly" # route_53 write and ec2:readonly access sufficient via IAM
```

Usage
=====

Databag storage of AWS Credentials should reside in the following keys:

 - `aws_access_key_id`
 - `aws_secret_access_key`

```json
{
    "aws_base": {
        "zone": "aws.zircote.com",
        "data_bag": {
            "name": "aws",
            "item": "readonly"
        }

    }
}

```
