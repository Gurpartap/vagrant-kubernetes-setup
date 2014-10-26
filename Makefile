all:
	./up.sh

vb virtualbox:
	vagrant up --provider virtualbox

vf vmware_fusion:
	vagrant up --provider vmware_fusion

p parallels:
	vagrant up --provider parallels

test:
	bundle install --path .bundle
	bundle exec rake spec

clean:
	vagrant destroy -f
