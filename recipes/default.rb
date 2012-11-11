#
# Cookbook Name:: aws_base
# Recipe:: default
#
# Copyright 2012, zircote
#
#
unless node['ec2']['instance_id'].to_s.strip.length == 0
  aws = data_bag_item(node[:aws_base][:data_bag][:name], node[:aws_base][:data_bag][:item])
  if node['ec2']['public_hostname'].to_s.strip.length == 0
    cname = node['ec2']['local_ipv4']
  else
    cname = node['ec2']['public_hostname']
  end

  execute "install_pip" do
    command "easy_install -U pip;pip install -U cli53"
    not_if "which cli53"
  end

  template "/usr/bin/ec2-name" do
    source "ec2-name.erb"
    owner "root"
    group "root"
    mode 0755
    variables(
        {:aws => aws}
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
      :hostname => node[:hostname]
    })
    notifies :restart, resources(:service => "network"), :immediately
    action :nothing
  end

  ruby_block "set and fetch hostnames" do
    block do
      command = "/usr/bin/ec2-name #{node[:ec2][:instance_id]} #{aws['aws_access_key_id']} #{aws['aws_secret_access_key']}"
      hostname = `#{command}`.sub('.' + node['route53']['zone'], '').to_s.strip()
      if hostname.length == 0
          hostname = node[:ec2][:instance_id]
      end
      node.automatic_attrs[:hostname] = hostname
      node.automatic_attrs[:fqdn] = "#{node['hostname']}.#{node['route53']['zone']}"
      record_type = 'A'
      unless /^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$/.match(cname)
        record_type = 'CNAME'
      end
      shell=<<-EOF
      export AWS_ACCESS_KEY_ID=#{aws['aws_access_key_id']}
      export AWS_SECRET_ACCESS_KEY=#{aws['aws_secret_access_key']}
      echo "127.0.0.1 #{node['fqdn']} #{node['hostname']} localhost" > /etc/hosts
      echo "#{node['hostname']}" > /etc/hostname
      hostname --file /etc/hostname
      cli53 rrcreate -x 600 -r #{node['route53']['zone']} #{node['hostname']} #{record_type} #{cname}
      EOF
      unless /Success/.match(`#{shell}`)
        Chef::Log.info("Failed to set Hostname")
      end
    end
    notifies :create, resources(:template => "/etc/dhcp/dhclient.conf"), :immediately
  end

end
