node.set['postgresql']['client']['packages'] =  [ "postgresql90", "postgresql90-devel"  ]
node.set['postgresql']['server']['packages'] = [ "postgresql90-devel", "postgresql90-server" ]

include_recipe "yumrepo::postgresql9"
include_recipe "postgresql::ruby"
include_recipe "database"

pg_conn_info = {
  :host => node['fedora']['db']['host'],
  :username => 'postgres',
  :password => node['postgresql']['password']['postgres']
}

postgresql_database_user node['fedora']['db']['username'] do
  username "\"#{node['fedora']['db']['username']}\""
  connection pg_conn_info
  password node['fedora']['db']['password']
  action :create
  ignore_failure true
end

postgresql_database "fedora" do
  connection pg_conn_info
  owner "\"#{node['fedora']['db']['username']}\""
  encoding 'UTF-8'
  action :create
end
