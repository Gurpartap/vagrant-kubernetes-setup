require "rake"
require "rspec/core/rake_task"

def find_vagrantfile
  Pathname.new(Dir.pwd).ascend do |dir|
    path = File.expand_path("Vagrantfile", dir)
    return path if File.exists?(path)
  end
  nil
end

def find_vagrant_vms
  list_of_vms = []
  if find_vagrantfile
    vagrant_list = `vagrant status`
    if vagrant_list != ""
      vagrant_list.each_line do |line|
        if match = /([\w-]+[\s]+)(created|aborted|not created|poweroff|running|saved)[\s](\(virtualbox\)|\(vmware\)|\(vmware_fusion\))/.match(line)
          list_of_vms << match[1].strip!
        end
      end
    else
      $stderr.puts "Vagrant status error - Check your Vagrantfile or .vagrant"
      exit 1
    end
  else
    $stderr.puts "Vagrantfile not found in directory!"
    exit 1
  end
  return list_of_vms
end

targets = find_vagrant_vms

task :spec    => "spec:all"
task :default => :spec

namespace :spec do
  task :all     => targets.map { |t| "spec:#{t}" }
  task :default => :all

  targets.each do |target|
    desc "Run serverspec tests to #{target}"
    RSpec::Core::RakeTask.new(target) do |t|
      ENV["TARGET_HOST"] = target
      if target =~ /minion/
        t.pattern = "spec/minion_spec.rb"
      else
        t.pattern = "spec/#{target}_spec.rb"
      end
    end
  end
end
