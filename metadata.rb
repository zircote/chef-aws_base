#
# Cookbook Name:: aws_base
# Recipe:: default
#
# Copyright 2012, zircote
#
#
maintainer       "Robert Allen @zircote"
maintainer_email "zircote@gmail.com"
license          "All rights reserved"
description      "Installs/Configures aws_base for Route53 hostname provisioning"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))

version          "0.1.2"


%w{ redhat centos fedora amazon scientific }.each do |os|
  supports os
end

depends "python"
