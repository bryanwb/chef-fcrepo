default['fedora']['user'] = "fedora"
default['fedora']['home'] = "/usr/local/fedora"
default['fedora']['installer_jar'] = 'http://downloads.sourceforge.net/fedora-commons/fcrepo-installer-3.5.jar'
default['fedora']['installer_checksum'] = 'c2fe897ee55bd4de4014b0d76ab5915a1356abcacca0b90f0a9d97d6d15b39bf'
default['fedora']['db']['host'] = 'localhost'
set['fedora']['db']['username'] = "fedoraadmin"
default['fedora']['db']['password'] = "fedoraadmin"

set['postgresql']['version'] = "9.0"
override['postgresql']['dir'] = '/var/lib/pgsql/9.0/data'
override['postgresql']['client']['packages'] =  [ "postgresql90", "postgresql90-devel"  ]
override['postgresql']['server']['packages'] = [ "postgresql90-devel", "postgresql90-server" ]
