# hashicluster/nomad - 10-server.hcl
#
# General configuration for Nomad servers.

server {
  bootstrap_expect = 3
  enabled          = true
}
