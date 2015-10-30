include_recipe 'deploy'
include_recipe "nginx::service"

node[:deploy].each do |application, deploy|
  if deploy[:application_type] != 'php'
    Chef::Log.debug("Skipping deploy::web application #{application} as it is not a php HTML app")
    next
  end

  opsworks_deploy_dir do
    user deploy[:user]
    group deploy[:group]
    path deploy[:deploy_to]
  end

  opsworks_deploy do
    app application
    deploy_data deploy
  end

  nginx_web_app application do
    application deploy
    cookbook "nginx"
  end

  if deploy[:application] == 'admin_api' or deploy[:application] == 'admin-api'

    Chef::Log.info(" ")
    Chef::Log.info("--- Joox Application name: " + deploy[:application] + " directory: " + deploy[:deploy_to])
    Chef::Log.info(" ")

    #####################
    # settings
    #####################

    Chef::Log.info(" ENV: " + deploy[:environment_variables].inspect)

    #####################
    # laravel actions
    #####################

    #Chef::Log.info(" Running: /usr/bin/php #{deploy[:deploy_to]}/current/artisan migrate")
    #Chef::Log.info(" Running: /usr/bin/php #{deploy[:deploy_to]}/current/artisan app:clear-cache")

    #####################
    # permissions
    #####################

    Chef::Log.info(" Fixing permissions: #{deploy[:deploy_to]}/current/storage")
    directory "#{deploy[:deploy_to]}/current/storage" do
      mode '0775'
      recursive true
    end

    Chef::Log.info(" Fixing permissions: #{deploy[:deploy_to]}/current/bootstrap/cache")
    directory "#{deploy[:deploy_to]}/current/bootstrap/cache" do
      mode '0775'
      recursive true
    end

    Chef::Log.info(" ")

  end

end
