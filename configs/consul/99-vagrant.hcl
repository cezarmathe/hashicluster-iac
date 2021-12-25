# hashiclusterc/consul - 99-vagrant.hcl
#
# Configuration for Consul when running in Vagrant.

bind_addr = "{{ GetInterfaceIP \"eth1\" }}"
