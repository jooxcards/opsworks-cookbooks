#
# Cookbook Name:: deploy
# Recipe:: web-restart

include_recipe 'deploy'

node[:deploy].each do |application, deploy|
  if deploy[:application_type] != 'php'
    Chef::Log.debug("Skipping deploy::web-restart application #{application} as it is not a php app")
    next
  end

  service 'nginx' do
    supports :status => true, :restart => true, :reload => true
    action :restart
  end
end
