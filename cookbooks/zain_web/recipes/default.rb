# Cookbook: zain_web
# Recipe: default
# Maqsad: nginx install, template se index page, service enable + start

package 'nginx' do
  action :install
end

package 'curl' do
  action :install
end

template '/var/www/html/index.html' do
  source 'index.html.erb'
  owner 'root'
  group 'root'
  mode '0644'
  action :create
end

service 'nginx' do
  action [:enable, :start]
end
