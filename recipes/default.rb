#
# Cookbook Name:: fcrepo
# Recipe:: default
#
# Copyright 2012, Bryan W. Berry
#
# Apache 2.0 license
#

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

cookbook_file "/etc/init.d/fedora" do
  source "fedora"
  owner "root"
  group "root"
  mode "0755"
end

remote_file "#{Chef::Config[:file_cache_path]}/fcrepo-installer.jar" do
  source  node['fedora']['installer_jar']
  checksum node['fedora']['installer_checksum'] 
  mode "0775"
end 

cookbook_file "#{Chef::Config[:file_cache_path]}/install.properties" do
  source "install.properties"
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

cookbook_file "#{node['fedora']['home']}/server/config/fedora-users.xml" do
  source "fedora-users.xml.erb"
  owner node['fedora']['user']
  group node['fedora']['user']
  mode "0755"
end

directory "#{node['fedora']['home']}/tomcat/conf/Catalina/localhost/solr.xml" do
  owner node['fedora']['user']
  group node['fedora']['user']
  mode "0755"
  recursive true
end

cookbook_file "#{node['fedora']['home']}/tomcat/conf/Catalina/localhost/solr.xml" do
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
end 

