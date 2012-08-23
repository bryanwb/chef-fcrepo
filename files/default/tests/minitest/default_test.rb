require 'minitest/spec'
require 'open3'

describe_recipe 'fcrepo::default' do

    # It's often convenient to load these includes in a separate
  # helper along with
  # your own helper methods, but here we just include them directly:
  include MiniTest::Chef::Assertions
  include MiniTest::Chef::Context
  include MiniTest::Chef::Resources

  before do
    fedora_ingest = "#{node['fedora']['home']}/client/bin/fedora-ingest-demos.sh"
    Open3.popen3("#{fedora_ingest} localhost 8080 fedoraAdmin fedoracms7 http") do |stdin,stdout,stderr|
      stdout.readlines.each do |line| 
        if line =~ /objects failed/
          puts "setup call failed"
        end
      end
    end
  end

  it "should return a couple demos" do
    Open3.popen3('fedora-find.sh localhost 8080 fedoraAdmin fedoracms7 "pid Type title description" "fedora" http') do |stdin,stdout,stderr|
      assert stdout.readlines.include?( "#1\n" ), "did not find demos"
    end
  end

  after do 
    require ::File.expand_path('./support/helper.rb', File.dirname(__FILE__))
    fedora_find = "#{node['fedora']['home']}/client/bin/fedora-purge.sh"
    pids_to_remove.each do |pid|
      Open3.popen3("#{fedora_find} localhost:8080 fedoraAdmin fedoracms7 #{pid} http ''") do |stdin,stdout,stderr|
        stderr.readlines.each do |line| 
          if line =~ /ERROR/
            puts "teardown call failed"
          end
        end
      end
    end
  end

end
































