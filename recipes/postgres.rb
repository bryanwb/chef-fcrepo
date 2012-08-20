include_recipe "yumrepo::postgresql9"

%w{ postgresql90-server postgresql90-devel postgresql90 postgresql90-libs }.each do |pkg|
   package pkg
end

ruby_block "create database" do
  block do
    system('/etc/init.d/postgresql-9.0 initdb')
    system('/etc/init.d/postgresql-9.0 start')
  end
end

bash "create role" do
  code <<-EOH
  psql -d postgres -c "CREATE ROLE \"fedoraAdmin\" LOGIN PASSWORD 'fedoraAdmin';"
  EOH
  user "postgres"
end

bash "create database" do
  code <<-EOH
  CREATE DATABASE "fedora3" WITH ENCODING='UTF8' OWNER=\"fedoraAdmin\";"
  EOH
  user "postgres"
end

