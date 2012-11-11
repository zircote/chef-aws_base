#
# Cookbook Name:: aws_base
# Recipe:: default
#
# Copyright 2012, zircote
#
#
unless node['ec2']['instance_id'].to_s.strip.length == 0

  include_recipe "python::pip"

  python_pip "cli53" do
    action [:install]
  end

  aws_r53 = data_bag_item(node[:aws_base][:data_bag][:route53][:name], node[:aws_base][:data_bag][:route53][:item])
  aws_ro = data_bag_item(node[:aws_base][:data_bag][:ec2][:name], node[:aws_base][:data_bag][:ec2][:item])
  if node['ec2']['public_hostname'].to_s.strip.length == 0
    cname = node['ec2']['local_ipv4']
  else
    cname = node['ec2']['public_hostname']
  end

  template "/usr/bin/ec2-name" do
    source "ec2-name.erb"
    owner "root"
    group "root"
    mode 0755
    variables(
        {:aws => aws_ro}
    )
  end

  service "network" do
    supports :status => true, :restart => true, :reload => true
    action :nothing
  end

  template "/etc/dhcp/dhclient.conf" do
    source "dhclient.conf.erb"
    owner "root"
    group "root"
    mode 0644
    variables({
      :hostname => node['hostname']
    })
    notifies :restart, resources(:service => "network"), :immediately
    action :nothing
  end

  ruby_block "set and fetch hostnames" do
    block do
      command = "/usr/bin/ec2-name #{node['ec2']['instance_id']} #{aws_ro['aws_access_key_id']} #{aws_ro['aws_secret_access_key']}"
      hostname = `#{command}`.sub('.' + node['aws_base']['zone'], '').to_s.strip()
      if hostname.length == 0
          hostname = node['ec2']['instance_id']
      end
      node.automatic_attrs[:hostname] = hostname
      node.automatic_attrs[:fqdn] = "#{node['hostname']}.#{node['aws_base']['zone']}"
      record_type = 'A'
      unless /^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$/.match(cname)
        record_type = 'CNAME'
      end
      shell=<<-EOF
      export AWS_ACCESS_KEY_ID=#{aws_r53['aws_access_key_id']}
      export AWS_SECRET_ACCESS_KEY=#{aws_r53['aws_secret_access_key']}
      echo "127.0.0.1 #{node['fqdn']} #{node['hostname']} localhost" > /etc/hosts
      echo "#{node['hostname']}" > /etc/hostname
      hostname --file /etc/hostname
      cli53 rrcreate -x 600 -r #{node['aws_base']['zone']} #{node['hostname']} #{record_type} #{cname}
      EOF
      unless /Success/.match(`#{shell}`)
        Chef::Log.info("Failed to set Hostname")
      end
    end
    notifies :create, resources(:template => "/etc/dhcp/dhclient.conf"), :immediately
  end

end
