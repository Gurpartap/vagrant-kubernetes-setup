all:
	vagrant up

vb virtualbox:
	vagrant up --provider virtualbox

vf vmware_fusion:
	vagrant up --provider vmware_fusion

p parallels:
	vagrant up --provider parallels

clean:
	vagrant destroy -f
