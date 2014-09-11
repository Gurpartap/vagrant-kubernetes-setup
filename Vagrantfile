# -*- mode: ruby -*-
# # vi: set ft=ruby :

require 'fileutils'

Vagrant.require_version ">= 1.6.0"

# Defaults for config options defined in CONFIG
$num_minions           = 1
$update_channel        = "alpha"
$enable_serial_logging = false
$vb_gui                = false
$vb_memory             = 1024
$vb_cpus               = 1
$base_ip_addr          = "172.17.8"

DISCOVERY_CONFIG_PATH  = File.join(File.dirname(__FILE__), "discovery.yml")
MASTER_CONFIG_PATH     = File.join(File.dirname(__FILE__), "master.yml")
MINION_CONFIG_PATH     = File.join(File.dirname(__FILE__), "minion.yml")
CONFIG                 = File.join(File.dirname(__FILE__), "config.rb")
BIN_PATH               = File.join(File.dirname(__FILE__), "bin")

require CONFIG if File.exist?(CONFIG)

$num_instances         = 1 + $num_minions # master + minions

ETCD_DISCOVERY         = "#{$base_ip_addr}.10"
MASTER_IP_ADDR         = "#{$base_ip_addr}.100"
MINION_IP_ADDRS        = (1..$num_minions).collect { |i| $base_ip_addr + ".#{i+100}" }

Vagrant.configure("2") do |config|
  config.vm.box = "coreos-%s" % $update_channel
  config.vm.box_version = ">= 423.0.0"
  config.vm.box_url = "http://%s.release.core-os.net/amd64-usr/current/coreos_production_vagrant.json" % $update_channel

  config.vm.provider :vmware_fusion do |vb, override|
    override.vm.box_url = "http://%s.release.core-os.net/amd64-usr/current/coreos_production_vagrant_vmware_fusion.json" % $update_channel
  end

  config.vm.provider :virtualbox do |v|
    # On VirtualBox, we don't have guest additions or a functional vboxsf
    # in CoreOS, so tell Vagrant that so it can be smarter.
    v.check_guest_additions = false
    v.functional_vboxsf     = false
  end

  # config.vm.provider :digital_ocean do |provider, override|
  #   override.ssh.private_key_path = '~/.ssh/id_rsa'
  #   override.vm.box = 'digital_ocean'
  #   override.vm.box_url = "https://github.com/smdahlen/vagrant-digitalocean/raw/master/box/digital_ocean.box"

  #   provider.token = ENV['DIGITAL_OCEAN_TOKEN']
  #   provider.image = 'CoreOS 431.0.0 (alpha)'
  #   provider.region = 'nyc3'
  #   provider.size = '512mb'
  #   provider.private_networking = true
  # end

  # plugin conflict
  if Vagrant.has_plugin?("vagrant-vbguest") then
    config.vbguest.auto_update = false
  end

  config.vm.define "discovery" do |discovery|
    discovery.vm.hostname = "discovery"

    discovery.vm.network :private_network, ip: ETCD_DISCOVERY

    discovery.vm.provision :file, source: DISCOVERY_CONFIG_PATH, destination: "/tmp/vagrantfile-user-data"
    discovery.vm.provision :shell, :inline => "mv /tmp/vagrantfile-user-data /var/lib/coreos-vagrant/", :privileged => true
  end

  (1..$num_instances).each do |i|
    is_master = (i == 1)
    vm_name = is_master ? "master" : "minion-#{i-1}"
    config.vm.define "#{vm_name}" % i do |config|
      config.vm.hostname = vm_name

      if $enable_serial_logging
        logdir = File.join(File.dirname(__FILE__), "log")
        FileUtils.mkdir_p(logdir)

        serialFile = File.join(logdir, "%s-serial.txt" % vm_name)
        FileUtils.touch(serialFile)

        config.vm.provider :vmware_fusion do |v, override|
          v.vmx["serial0.present"]     = "TRUE"
          v.vmx["serial0.fileType"]    = "file"
          v.vmx["serial0.fileName"]    = serialFile
          v.vmx["serial0.tryNoRxLoss"] = "FALSE"
        end

        config.vm.provider :virtualbox do |vb, override|
          vb.customize ["modifyvm", :id, "--uart1", "0x3F8", "4"]
          vb.customize ["modifyvm", :id, "--uartmode1", serialFile]
        end
      end

      if $expose_docker_tcp
        config.vm.network "forwarded_port", guest: 2375, host: ($expose_docker_tcp + i - 1), auto_correct: true
      end

      config.vm.provider :vmware_fusion do |vb|
        vb.gui = $vb_gui
      end

      config.vm.provider :virtualbox do |vb|
        vb.gui    = $vb_gui
        vb.memory = $vb_memory
        vb.cpus   = $vb_cpus
      end

      # Uncomment below to enable NFS for sharing the host machine into the coreos-vagrant VM.
      #config.vm.synced_folder ".", "/home/core/share", id: "core", :nfs => true, :mount_options => ['nolock,vers=3,udp']

      ip_sed_command   = "sed -e \"s/%MINION_IP_ADDRS%/#{MINION_IP_ADDRS.join(',')}/g\" -i /tmp/vagrantfile-user-data"
      etcd_sed_command = "sed -e \"s/%ETCD_DISCOVERY%/#{ETCD_DISCOVERY}/g\" -i /tmp/vagrantfile-user-data"

      if is_master
        config.vm.network :forwarded_port, guest: 4001, host: 4001
        private_network_ip = MASTER_IP_ADDR
        cloud_config_path = MASTER_CONFIG_PATH
      else
        private_network_ip = MINION_IP_ADDRS[i-2]
        cloud_config_path = MINION_CONFIG_PATH
      end

      config.vm.network :private_network, ip: private_network_ip
      config.vm.provision :file, :source => "#{cloud_config_path}", :destination => "/tmp/vagrantfile-user-data"

      commands = []
      commands << ip_sed_command if is_master
      commands << etcd_sed_command
      commands << "mv /tmp/vagrantfile-user-data /var/lib/coreos-vagrant/"

      config.vm.provision :shell, :inline => commands.join(" && "), :privileged => true

      config.vm.provision :shell, :inline => "mkdir -p /opt/bin",  :privileged => true
      Dir.foreach(BIN_PATH) do |file|
        next if file =~ /\./
        config.vm.provision :file, :source => "#{BIN_PATH}/#{file}", :destination => "/tmp/#{file}"
        config.vm.provision :shell, :inline => "mv /tmp/#{file} /opt/bin/#{file} && /usr/bin/chmod +x /opt/bin/#{file}",  :privileged => true
      end

      unless File.exist?("#{BIN_PATH}/rudder")
        config.vm.provision :docker do |docker|
          docker.run "gurpartap/rudder",
            args: "--rm -v /opt/bin:/opt/bin",
            auto_assign_name: false, daemonize: false
        end
      end
    end
  end
end
