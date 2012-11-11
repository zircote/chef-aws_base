#
# Cookbook Name:: aws_base
# Recipe:: default
#
# Copyright 2012, zircote
#
default[:aws_base][:zone] = nil
default[:aws_base][:data_bag][:route53][:name] = "aws"
default[:aws_base][:data_bag][:route53][:item] = "r53-rw"
default[:aws_base][:data_bag][:ec2][:name] = "aws"
default[:aws_base][:data_bag][:ec2][:item] = "ec2-ro"

