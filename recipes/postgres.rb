include_recipe "yumrepo::postgresql9"

%w{ postgresql90-server postgresql90-devel postgresql90 postgresql90-libs }.each do |pkg|
   package pkg
end

chef_gem "pry"
chef_gem "pry-nav"
chef_gem "pry-doc"

chef_gem "pg" do
  action :nothing
end

ruby_block "create database" do
  block do
    require 'fileutils'
    FileUtils.rm_rf "/var/lib/pgsql/9.0/data"
    system('/etc/init.d/postgresql-9.0 initdb')
  end
  not_if {::File.exists? "/var/lib/pgsql/9.0/data/PG_VERSION" }
end

link "/usr/bin/pg_config" do
  to "/usr/pgsql-9.0/bin/pg_config"
  notifies :install, "chef_gem[pg]", :immediately
end

cookbook_file "/var/lib/pgsql/9.0/data/pg_hba.conf" do
  source "pg_hba.conf"
  owner "postgres"
end

ruby_block "start database" do
  block do
    system('/etc/init.d/postgresql-9.0 start')
  end
end

# bash "set silly password for postgres" do

#   code <<-EOF
#     psql -d postgres -c "alter role postgres with password 'postgres'" 
#   EOF
#   user 'postgres'
# end

ruby_block "create role and database" do
  block do
    Gem.clear_paths
    require 'pg'
    conn = PG.connect( dbname: 'postgres', user: 'postgres')
    result_role = conn.exec("CREATE ROLE \"fedoraAdmin\" WITH LOGIN PASSWORD 'fedoraadmin'")
    result_passwd = conn.exec("CREATE DATABASE fedora WITH ENCODING='UTF8' OWNER=\"fedorAdmin\"")
  end
  only_if do
    Gem.clear_paths 
    require 'pg'
    conn = PG.connect( dbname: 'postgres', user: 'postgres')
    count = conn.exec("select datname from pg_database where datname='fedora'").values.flatten!
    Chef::Log.debug("count.length is #{count.length}") 
    count.length == 0
  end
end

# bash "create role" do
#   code <<-EOH
#   psql -d postgres -c "CREATE ROLE \"fedoraAdmin\" LOGIN PASSWORD 'fedoraAdmin';"
#   EOH
#   user "postgres"
#   ignore_failure true
# end

# bash "create database" do
#   code <<-EOH
#   psql -d postgres -c "CREATE DATABASE \"fedora\" WITH ENCODING='UTF8' OWNER=\"fedoraAdmin\";"
#   EOH
#   user "postgres"
#   ignore_failure true
# end

