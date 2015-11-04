# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'


## Example file
# aws:
#   access_id: ID
#   secret_key: KEY
#   remote_url: s3+http://bucket.name/backups/test/

settings = YAML.load_file '.envs.yml'

Vagrant.configure("2") do |config|
  config.vm.synced_folder ".", "/vagrant", disabled: true

  config.vm.provider "docker" do |d|
    d.vagrant_vagrantfile = "host/Vagrantfile"
    d.build_dir = "."
    d.has_ssh = false
    d.env = {
        AWS_ACCESS_KEY_ID: settings['aws']['access_id'],
        AWS_SECRET_ACCESS_KEY: settings['aws']['secret_key'],
        REMOTE_URL: settings['aws']['remote_url'],
        SOURCE_PATH: "/var/lib/systemd",
        CRON_SCHEDULE: "*/10 * * * *",
        PASSPHRASE: "s3cr3t"
    }
  end
end
