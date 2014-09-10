
# To automatically replace the discovery token on 'vagrant up', uncomment
# the lines below:

# %w['master.yml', 'minion.yml'].each do |config|
#   if File.exists?(config) && ARGV[0].eql?('up')
#    require 'open-uri'
#    require 'yaml'

#    token = open('https://discovery.etcd.io/new').read

#    data = YAML.load(IO.readlines(config)[1..-1].join)
#    data['coreos']['etcd']['discovery'] = token

#    lines = YAML.dump(data).split("\n")
#    lines[0] = '#cloud-config'

#    open(config, 'r+') do |f|
#      f.puts(lines.join("\n"))
#    end
#   end
# end

# coreos-vagrant is configured through a series of configuration
# options (global ruby variables) which are detailed below. To modify
# these options, first copy this file to "config.rb". Then simply
# uncomment the necessary lines, leaving the $, and replace everything
# after the equals sign..

# Number of minions in the CoreOS cluster created by Vagrant
$num_minions = 2

# Official CoreOS channel from which updates should be downloaded
$update_channel = 'alpha'

# Log the serial consoles of CoreOS VMs to log/
# Enable by setting value to true, disable with false
# WARNING: Serial logging is known to result in extremely high CPU usage with
# VirtualBox, so should only be used in debugging situations
$enable_serial_logging = false

# Enable port forwarding of Docker TCP socket
# Set to the TCP port you want exposed on the *host* machine, default is 2375
# If 2375 is used, Vagrant will auto-increment (e.g. in the case of $num_instances > 1)
# You can then use the docker tool locally by setting the following env var:
#   export DOCKER_HOST='tcp://127.0.0.1:2375'
$expose_docker_tcp = 2375

# Setting for VirtualBox VMs
$vb_gui = false
$vb_memory = 1024
$vb_cpus = 1

# discovery: .99
# master: .100
# minions: .101..10n
$base_ip_addr = "172.17.8"
