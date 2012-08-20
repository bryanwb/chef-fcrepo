maintainer       "Bryan W. Berry"
maintainer_email "bryan.berry@gmail.com"
license          "Apache v2.0"
description      "Installs/Configures fedora-commons"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.0.1"

%w{ java }.each do |cb|
  depends cb
end

%w{ centos redhat debian ubuntu }.each do |os|
  supports os
end
