require "spec_helper"

%w[flanneld kubelet proxy].each do |f|
  describe file("/opt/bin/#{f}") do
    it { should be_file }
    it { should be_owned_by "core" }
    it { should be_executable }
  end
end

%w[etcd docker flanneld kubelet proxy].each do |p|
  describe process(p) do
    it { should be_running }
  end
end

describe file("/run/flannel/subnet.env") do
  it { should be_file }
end

describe file("/etc/systemd/system/docker.service.d/10-flannel.conf") do
  it { should be_file }
  its(:content) { should match /.*Requires=flanneld.service.*/ }
end

describe port(10250) do
  it { should be_listening }
end

describe port(4001) do
  it { should be_listening }
end

describe port(7001) do
  it { should be_listening }
end
