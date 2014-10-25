require "serverspec"
require "net/ssh"
require "tempfile"

set :backend, :ssh

host = ENV["TARGET_HOST"]

`vagrant up #{host}`

config = Tempfile.new("", Dir.tmpdir)
`vagrant ssh-config #{host} > #{config.path}`

options = Net::SSH::Config.for(host, [config.path])

options[:user] ||= Etc.getlogin

set :os, :family => "redhat", :release => "7", :arch => "x86_64"
set :host, options[:host_name] || host
set :ssh_options, options
set :disable_sudo, true

# Set environment variables
# set :env, :LANG => "C", :LC_MESSAGES => "C" 

# Set PATH
# set :path, "/sbin:/usr/local/sbin:$PATH"
