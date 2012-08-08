
Vagrant::Config.run do |config|

  config.vm.box = "centos6_32"
  config.vm.box_url = 'http://vagrant.sensuapp.org/centos-6-i386.box'

  config.vm.provision :chef_solo do |chef|
    chef.cookbooks_path = ["/tmp/cookbooks", "/tmp/chef-repo"]
    chef.add_recipe "ark"
    chef.add_recipe "java"    
    chef.add_recipe "tomcat::base"
    chef.add_recipe "yum::epel"
    chef.add_recipe "maven"
#    chef.add_recipe "mysql::server"
#    chef.add_recipe "database"
    chef.add_recipe "fedora-commons"
    chef.json = {  :mysql => {:server_root_password => "fedora567"}, :tomcat => {:http_port => "8080"}}
  end

end
