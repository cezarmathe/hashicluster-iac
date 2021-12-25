# hashiclusterc/nomad - 99-vagrant.hcl
#
# Configuration for Nomad when running in Vagrant.

bind_addr = "{{ GetInterfaceIP \"eth1\" }}"

client {
  network_interface = "eth1"
}
