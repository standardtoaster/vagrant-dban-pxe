# vim: syntax=ruby:expandtab:shiftwidth=2:softtabstop=2:tabstop=2

execute "Disabling SELinux" do
  command "setenforce 0"
end
template "/etc/selinux/config" do
  source "selinux.erb"
  mode 0644
  owner "root"
  group "root"
end

['dnsmasq', 'syslinux-tftpboot'].each do |pkg|
  package pkg do
    action :install
  end
end

template "/etc/dnsmasq.conf" do
  source "dnsmasq.conf.erb"
  mode 0644
  owner "root"
  group "root"
end

['dnsmasq'].each do |svc|
  service svc do
    supports :restart => true
    action [:enable, :start]
  end
end

service 'iptables' do
  action [:stop, :disable]
end

['/tftpboot/pxelinux.cfg', '/tftpboot/dban'].each do |dirname|
  directory dirname do
    owner "nobody"
    group "nobody"
    mode 0777
    action :create
  end
end

template "/tftpboot/pxelinux.cfg/default" do
  source "default.erb"
  mode 0777
  owner "root"
  group "root"
end

mount "/tftpboot/dban" do
  device "/vagrant/dban-2.2.8_i586.iso"
  options "loop"
end
