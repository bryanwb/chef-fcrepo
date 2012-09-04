#
# Cookbook Name:: fcrepo
# Recipe:: default
#
# Copyright 2012, Bryan W. Berry
#
# Apache 2.0 license
#

include_recipe "maven"

user node['fedora']['user']

directory node['fedora']['home'] do
  owner node['fedora']['user']
  group node['fedora']['user']
  mode "0755"
  action :create
end

template "/etc/default/fedora" do
  owner "root"
  group "root"
  mode "0755"
  source "default_fedora.erb"
end

file "/etc/profile.d/fedora.sh" do
  content "source /etc/default/fedora"
  owner "root"
  mode  "0755"
end

template "/etc/init.d/fedora" do
  source "fedora.init.el.erb"
  owner "root"
  group "root"
  mode "0755"
end

directory "/var/run/fedora" do
  owner "fedora"
  group "fedora"
  mode "0755"
end

remote_file "#{Chef::Config[:file_cache_path]}/fcrepo-installer.jar" do
  source  node['fedora']['installer_jar']
  checksum node['fedora']['installer_checksum'] 
  mode "0775"
end 

template "#{Chef::Config[:file_cache_path]}/install.properties" do
  source "install.properties.erb"
  owner "root"
  group "root"
  mode "0644"
end

maven "postgresql" do
  group_id "postgresql"
  version "9.0-801.jdbc4"
  dest Chef::Config[:file_cache_path]
end

execute "install fedora" do
  user node['fedora']['user']
  group node['fedora']['user'] 
  command "java -jar #{Chef::Config[:file_cache_path]}/fcrepo-installer.jar #{Chef::Config[:file_cache_path]}/install.properties"
  creates "#{node['fedora']['home']}/tomcat"
  action :run
end

cookbook_file "#{node['fedora']['home']}/server/config/fedora.fcfg" do
  source "fedora.fcfg"
  owner node['fedora']['user']
  group node['fedora']['user']
  mode "0755"
end
template "#{node['fedora']['home']}/server/config/fedora-users.xml" do
  source "fedora-users.xml.erb"
  owner node['fedora']['user']
  group node['fedora']['user']
  mode "0755"
end

directory "#{node['fedora']['home']}/tomcat/conf/Catalina/localhost" do
  owner node['fedora']['user']
  group node['fedora']['user']
  mode "0755"
  recursive true
end

service "fedora" do
  action [ :enable, :start ]
end

cron "compress rotated" do
  minute "0"
  hour   "0"
  command  "find  #{node['fedora']['home']}/logs -name '*.gz' -mtime +60 -exec rm -f '{}' \\; ; \
  find #{node['fedora']['home']}/logs ! -name '*.gz' -mtime +2 -exec gzip '{}' \\;"
end
