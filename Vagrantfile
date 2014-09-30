# -*- mode: ruby -*-
# # vi: set ft=ruby :

require 'fileutils'

$number_of_minions = 3
coreos_channel = "alpha"
coreos_minimum_version = "423.0.0"
enable_serial_logging = false

$base_ip_addr = "172.17.8"

def discovery_ip_addr; "#{$base_ip_addr}.10"; end
def master_ip_addr; "#{$base_ip_addr}.100"; end
def minion_ip_addrs; (1..$number_of_minions).collect { |i| $base_ip_addr + ".#{i+100}" }; end

discovery_config_path  = File.join(File.dirname(__FILE__), "discovery.yml")
master_config_path = File.join(File.dirname(__FILE__), "master.yml")
minion_config_path = File.join(File.dirname(__FILE__), "minion.yml")
bin_path = File.join(File.dirname(__FILE__), "bin")

move_user_data_cmd = "mv /tmp/vagrantfile-user-data /var/lib/coreos-vagrant/"
etcd_discovery_cmd = "sed -e \"s/%discovery_ip_addr%/#{discovery_ip_addr}/g\" -i /tmp/vagrantfile-user-data"

Vagrant.require_version ">= 1.6.0"
Vagrant.configure("2") do |config|
  config.vm.box = "coreos-#{coreos_channel}"
  config.vm.box_version = ">= #{coreos_minimum_version}"
  config.vm.box_url = "http://#{coreos_channel}.release.core-os.net/amd64-usr/current/coreos_production_vagrant.json"

  # Enable NFS for sharing the host machine into the coreos-vagrant VM.
  # config.vm.synced_folder ".", "/home/core/share", id: "core", :nfs => true, :mount_options => ['nolock,vers=3,udp']

  config.nfs.functional = false

  config.vm.provider "virtualbox" do |vb|
    # On VirtualBox, we don't have guest additions or a functional vboxsf
    # in CoreOS, so tell Vagrant that so it can be smarter.
    vb.check_guest_additions = false
    vb.functional_vboxsf = false

    # Fix docker not being able to resolve private registry in VirtualBox
    vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
  end

  config.vm.provider "vmware_fusion" do |vf, override|
    override.vm.box_url = "http://#{coreos_channel}.release.core-os.net/amd64-usr/current/coreos_production_vagrant_vmware_fusion.json"
    # vf.gui = true

    vf.functional_hgfs = false
  end

  config.vm.provider "parallels" do |v|
    v.functional_psf    = false
    v.check_guest_tools = false
  end

  # Resolve issue with a specific Vagrant plugin by preventing it from updating.
  if Vagrant.has_plugin?("vagrant-vbguest")
    config.vbguest.auto_update = false
  end

  disable_update_engine = ->(node: node) {
    # reboot-strategy doesn't allowing stopping coreos from downloading updates in the background.
    node.vm.provision :shell, :inline => "systemctl stop update-engine.service && systemctl mask update-engine.service", :privileged => true
  }

  setup = ->(node: node, vm_name: vm_name, ip_addr: ip_addr, binaries: binaries) {
    if enable_serial_logging
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

    node.vm.hostname = vm_name
    node.vm.network :private_network, ip: ip_addr

    commands = [etcd_discovery_cmd, move_user_data_cmd, "mkdir -p /opt/bin"]

    binaries.each do |file|
      next unless File.exist?("#{bin_path}/#{file}")
      node.vm.provision :file, :source => "#{bin_path}/#{file}", :destination => "/tmp/#{file}"
      commands << "mv /tmp/#{file} /opt/bin/#{file}"
      commands << "/usr/bin/chmod +x /opt/bin/#{file}"
    end

    node.vm.provision :shell, :inline => commands.join(' && '),  :privileged => true
  }

  config.vm.define "discovery" do |discovery|
    discovery.vm.network :private_network, ip: discovery_ip_addr
    discovery.vm.provision :file, source: discovery_config_path, destination: "/tmp/vagrantfile-user-data"
    discovery.vm.provision :shell, :inline => "mv /tmp/vagrantfile-user-data /var/lib/coreos-vagrant/", :privileged => true
    disable_update_engine.call(node: discovery)
  end

  config.vm.define "master" do |master|
    # master.vm.network :forwarded_port, guest: 4001, host: 4001
    master.vm.provision :file, :source => master_config_path, :destination => "/tmp/vagrantfile-user-data"
    master.vm.provision :shell, :inline => "sed -e \"s/%minion_ip_addrs%/#{minion_ip_addrs.join(',')}/g\" -i /tmp/vagrantfile-user-data", :privileged => true
    setup.call(
      node: master,
      vm_name: "master",
      ip_addr: master_ip_addr,
      binaries: %w[flanneld kubecfg controller-manager apiserver scheduler]
    )
    disable_update_engine.call(node: master)
  end

  (1..$number_of_minions).each do |i|
    config.vm.define "minion-#{i}" do |minion|
      minion.vm.provision :file, :source => minion_config_path, :destination => "/tmp/vagrantfile-user-data"
      setup.call(
        node: minion,
        vm_name: "minion-#{i}",
        ip_addr: minion_ip_addrs[i-1],
        binaries: %w[flanneld kubelet proxy]
      )
      disable_update_engine.call(node: minion)
    end
  end
end
