#
# Cookbook Name:: fcrepo
# Recipe:: default
#
# Copyright 2012, Bryan W. Berry
#
# Apache 2.0 license
#


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
  source "init.el.erb"
  owner "root"
  group "root"
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

execute "install fedora" do
  user node['fedora']['user']
  group node['fedora']['user'] 
  command "java -jar #{Chef::Config[:file_cache_path]}/fcrepo-installer.jar #{Chef::Config[:file_cache_path]}/install.properties"
  creates "#{node['fedora']['home']}/tomcat"
  action :run
end

%w{ solr gsearch }.each do |subdir|
  directory "#{node['fedora']['home']}/#{subdir}" do
    owner node['fedora']['user']
    group node['fedora']['user']
    mode "0755"
    action :create
  end
end 

# cookbook_file "#{node['fedora']['home']}/server/config/fedora.fcfg" do
#   source "fedora.fcfg"
#   owner node['fedora']['user']
#   group node['fedora']['user']
#   mode "0755"
# end

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

template "#{node['fedora']['home']}/tomcat/conf/Catalina/localhost/solr.xml" do
  source "solr.xml.erb"
  owner node['fedora']['user']
  group node['fedora']['user']
  mode "0755"
end

maven "solr" do
  group_id "org.apache.solr"
  version "3.6.1"
  dest "#{node['fedora']['home']}/solr"
  packaging "war"
  action :put
end 

service "fedora" do
  action [ :enable, :start ]
end

logrotate_app node['fedora']['user'] do
  cookbook "logrotate"
  path     "#{node['fedora']['home']}/logs/catalina.out"
  frequency "daily"
  rotate    30
  create    "664 #{node['fedora']['user']} #{node['fedora']['user']}"
end

cron "compress rotated" do
  minute "0"
  hour   "0"
  command  "find  #{node['fedora']['home']}/logs -name '*.gz' -mtime +60 -exec rm -f '{}' \\; ; \
  find #{node['fedora']['home']}/logs ! -name '*.gz' -mtime +2 -exec gzip '{}' \\;"
end
