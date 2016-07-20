include_recipe 'deploy'

unless File.exists?("/usr/bin/composer")
  system "wget https://getcomposer.org/installer -O /tmp/composer-setup.php && php /tmp/composer-setup.php --force --install-dir=/usr/bin --filename=composer"
end

if File.directory?("#{deploy[:deploy_to]}")

  Chef::Log.info(" ")
  Chef::Log.info("--- Joox Application name: " + deploy[:application] + " directory: " + deploy[:deploy_to])
  Chef::Log.info(" ")

  #####################
  # settings
  #####################

  apiconfig = File.read("#{deploy[:deploy_to]}/current/.env.example")

  deploy[:environment_variables].each do |env_key, env_value|
    apiconfig = apiconfig.gsub(/^#{env_key}=.*/, "#{env_key}=#{env_value}")
  end

  newconfig = File.open("#{deploy[:deploy_to]}/current/.env", "w")
  newconfig.puts(apiconfig)
  newconfig.close

  Chef::Log.info(" Config saved to #{deploy[:deploy_to]}/current/.env")

  #####################
  # permissions
  #####################

  Chef::Log.info(" Fixing permissions: #{deploy[:deploy_to]}/current/storage")
  directory "#{deploy[:deploy_to]}/current/storage" do
    mode '0777'
    recursive true
  end
  directory "#{deploy[:deploy_to]}/current/storage/app" do
    mode '0777'
    recursive true
  end
  directory "#{deploy[:deploy_to]}/current/storage/logs" do
    mode '0777'
    recursive true
  end
  directory "#{deploy[:deploy_to]}/current/storage/framework" do
    mode '0777'
    recursive true
  end
  directory "#{deploy[:deploy_to]}/current/storage/framework/sessions" do
    mode '0777'
    recursive true
  end
  directory "#{deploy[:deploy_to]}/current/storage/framework/cache" do
    mode '0777'
    recursive true
  end
  directory "#{deploy[:deploy_to]}/current/storage/framework/views" do
    mode '0777'
    recursive true
  end

  Chef::Log.info(" Fixing permissions: #{deploy[:deploy_to]}/current/bootstrap/cache")
  directory "#{deploy[:deploy_to]}/current/bootstrap/cache" do
    mode '0777'
    recursive true
  end

  Chef::Log.info(" ")

  #####################
  # composer actions
  #####################

  system "/usr/bin/composer update -d #{deploy[:deploy_to]}/current --no-scripts"
  system "/usr/bin/composer install -d #{deploy[:deploy_to]}/current --no-scripts"
  system "/usr/bin/composer dumpautoload -d #{deploy[:deploy_to]}/current"

  #####################
  # laravel actions
  #####################

  Chef::Log.info(" Running: /usr/bin/php #{deploy[:deploy_to]}/current/artisan migrate")
  system "/usr/bin/php #{deploy[:deploy_to]}/current/artisan migrate"

  Chef::Log.info(" Running: /usr/bin/php #{deploy[:deploy_to]}/current/artisan app:clear-cache")
  system "/usr/bin/php #{deploy[:deploy_to]}/current/artisan app:clear-cache"

end
