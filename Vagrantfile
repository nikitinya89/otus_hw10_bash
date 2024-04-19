# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "generic/ubuntu2204"
  config.vm.synced_folder "./", "/vagrant/"
  config.vm.provision "shell", inline: <<-SHELL
    sudo apt install -y sendmail
    sudo mkdir /var/log/nginx
    sudo cp /vagrant/access.log /var/log/nginx/
    sudo cp /vagrant/nginx_report.sh /opt/
    sudo chmod +x /opt/nginx_report.sh
    TEMP_CRON=$(mktemp)
    sudo crontab -l >> $TEMP_CRON
    echo "0 * * * * /opt/nginx_report.sh" >> $TEMP_CRON
    sudo crontab $TEMP_CRON
    rm $TEMP_CRON
    SHELL
end
