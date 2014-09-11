# -*- mode: ruby -*-
# # vi: set ft=ruby :

require 'fileutils'

NUMBER_OF_MINIONS = 2
COREOS_CHANNEL = "alpha"
COREOS_MINIMUM_VERSION = "423.0.0"
ENABLE_SERIAL_LOGGING = false

BASE_IP_ADDR = "172.17.8"
ETCD_DISCOVERY = "#{BASE_IP_ADDR}.10"
MASTER_IP_ADDR = "#{BASE_IP_ADDR}.100"
MINION_IP_ADDRS = (1..NUMBER_OF_MINIONS).collect { |i| BASE_IP_ADDR + ".#{i+100}" }

DISCOVERY_CONFIG_PATH  = File.join(File.dirname(__FILE__), "discovery.yml")
MASTER_CONFIG_PATH = File.join(File.dirname(__FILE__), "master.yml")
MINION_CONFIG_PATH = File.join(File.dirname(__FILE__), "minion.yml")
BIN_PATH = File.join(File.dirname(__FILE__), "bin")

MOVE_USER_DATA_CMD = "mv /tmp/vagrantfile-user-data /var/lib/coreos-vagrant/"
ETCD_DISCOVERY_CMD = "sed -e \"s/%ETCD_DISCOVERY%/#{ETCD_DISCOVERY}/g\" -i /tmp/vagrantfile-user-data"

Vagrant.require_version ">= 1.6.0"
Vagrant.configure("2") do |config|
  config.vm.box = "coreos-#{COREOS_CHANNEL}"
  config.vm.box_version = ">= #{COREOS_MINIMUM_VERSION}"
  config.vm.box_url = "http://#{COREOS_CHANNEL}.release.core-os.net/amd64-usr/current/coreos_production_vagrant.json"

  config.vm.provider :virtualbox do |v|
    # On VirtualBox, we don't have guest additions or a functional vboxsf
    # in CoreOS, so tell Vagrant that so it can be smarter.
    v.check_guest_additions = false
    v.functional_vboxsf = false
  end

  config.vm.provider :vmware_fusion do |v, override|
    override.vm.box_url = "http://#{COREOS_CHANNEL}.release.core-os.net/amd64-usr/current/coreos_production_vagrant_vmware_fusion.json"
  end

  # Resolve issue with a specific Vagrant plugin by preventing it from updating.
  if Vagrant.has_plugin?("vagrant-vbguest")
    config.vbguest.auto_update = false
  end

  config.vm.define "discovery" do |discovery|
    discovery.vm.hostname = "discovery"
    discovery.vm.network :private_network, ip: ETCD_DISCOVERY
    discovery.vm.provision :file, source: DISCOVERY_CONFIG_PATH, destination: "/tmp/vagrantfile-user-data"
    discovery.vm.provision :shell, :inline => "mv /tmp/vagrantfile-user-data /var/lib/coreos-vagrant/", :privileged => true
  end

  provision = ->(m, files, vm_name) {
    if ENABLE_SERIAL_LOGGING
      logdir = File.join(File.dirname(__FILE__), "log")
      FileUtils.mkdir_p(logdir)

      serialFile = File.join(logdir, "#{vm_name}-serial.txt")
      FileUtils.touch(serialFile)

      config.vm.provider :virtualbox do |vb, override|
        vb.customize ["modifyvm", :id, "--uart1", "0x3F8", "4"]
        vb.customize ["modifyvm", :id, "--uartmode1", serialFile]
      end

      config.vm.provider :vmware_fusion do |v, override|
        v.vmx["serial0.present"]     = "TRUE"
        v.vmx["serial0.fileType"]    = "file"
        v.vmx["serial0.fileName"]    = serialFile
        v.vmx["serial0.tryNoRxLoss"] = "FALSE"
      end
    end

    # Uncomment below to enable NFS for sharing the host machine into the coreos-vagrant VM.
    #config.vm.synced_folder ".", "/home/core/share", id: "core", :nfs => true, :mount_options => ['nolock,vers=3,udp']

    m.vm.provision :shell, :inline => ETCD_DISCOVERY_CMD, :privileged => true
    m.vm.provision :shell, :inline => MOVE_USER_DATA_CMD, :privileged => true
    m.vm.provision :shell, :inline => "mkdir -p /opt/bin",  :privileged => true
    files.each do |file|
      next unless File.exist?("#{BIN_PATH}/#{file}")
      m.vm.provision :file, :source => "#{BIN_PATH}/#{file}", :destination => "/tmp/#{file}"
      m.vm.provision :shell, :inline => "mv /tmp/#{file} /opt/bin/#{file} && /usr/bin/chmod +x /opt/bin/#{file}",  :privileged => true
    end
  }

  config.vm.define "master" do |master|
    master.vm.hostname = "master"
    master.vm.network :private_network, ip: MASTER_IP_ADDR
    master.vm.network :forwarded_port, guest: 4001, host: 4001

    master.vm.provision :file, :source => MASTER_CONFIG_PATH, :destination => "/tmp/vagrantfile-user-data"
    master.vm.provision :shell, :inline => "sed -e \"s/%MINION_IP_ADDRS%/#{MINION_IP_ADDRS.join(',')}/g\" -i /tmp/vagrantfile-user-data", :privileged => true

    provision.call(master, %w[rudder kubecfg controller-manager apiserver scheduler], "master")
  end

  (1..NUMBER_OF_MINIONS).each do |i|
    config.vm.define "minion-#{i}" do |minion|
      minion.vm.hostname = "minion-#{i}"
      minion.vm.network :private_network, ip: MINION_IP_ADDRS[i-1]

      minion.vm.provision :file, :source => MINION_CONFIG_PATH, :destination => "/tmp/vagrantfile-user-data"

      provision.call(minion, %w[rudder kubelet proxy scheduler], "minion-#{i}")
    end
  end
end
