distros = {
  :lucid32 => {
    :url    => 'https://opscode-vm.s3.amazonaws.com/vagrant/boxes/opscode-ubuntu-10.04.box-i386',
    :run_list => [ "apt" ]
  },
  :centos6_3_32 => {
    :url      => 'https://opscode-vm.s3.amazonaws.com/vagrant/boxes/opscode-centos-6.3-i386.box',
    :run_list => [ "yum::epel", "yumrepo::postgresql9" ]
  }
}

Vagrant::Config.run do |config|
  distros.each_pair do |name,options|
    config.vm.define name do |dist_config|
      
      dist_config.vm.box = name.to_s
      dist_config.vm.box_url = options[:url]
      dist_config.vm.customize [ "modifyvm", :id, "--memory", "1024" ]      
      dist_config.vm.provision :chef_solo do |chef|
        chef.cookbooks_path = ["cookbooks"]
        chef.provisioning_path = '/etc/vagrant-chef' 
        chef.log_level         = :debug		 
        chef.add_recipe "minitest-handler"
	chef.add_recipe "postgresql::server"
        chef.add_recipe "yumrepo::postgresql9"
        chef.add_recipe "fcrepo::postgres"
	chef.add_recipe "fcrepo"	

        if options[:run_list]
          options[:run_list].each {|recipe| chef.run_list.insert(0, recipe) }
        end

        chef.json = {
          :java => {
            :install_flavor => "oracle",
            :oracle => {
              :accept_onerous_download_terms => true
            }
          }
        }
      end
    end
  end
end

