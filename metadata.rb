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
description      "Installs/Configures aws_base"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))

version          "0.1.1"


%w{ ubuntu debian redhat centos fedora amazon scientific freebsd openbsd }.each do |os|
  supports os
end

