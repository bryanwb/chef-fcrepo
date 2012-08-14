
Vagrant::Config.run do |config|

  config.vm.box = "centos6_32"
  config.vm.box_url = 'http://vagrant.sensuapp.org/centos-6-i386.box'

  config.vm.provision :chef_solo do |chef|
    chef.cookbooks_path = ["/tmp/cookbooks", "/tmp/chef-repo"]
    chef.provisioning_path = '/etc/vagrant-chef' 
    chef.log_level         = :debug		 
    chef.add_recipe "ark"
    chef.add_recipe "java"    
    chef.add_recipe "yum::epel"
    chef.add_recipe "maven"
    chef.add_recipe "yumrepo::postgresql9"
#    chef.add_recipe "mysql::server"
#    chef.add_recipe "database"
    chef.json = {  :mysql => {:server_root_password => "fedora567"}, :tomcat => {:http_port => "8080"}}
  end

end
