# hashicluster/consul - 10-server.hcl
#
# General configuration for Consul servers.

bootstrap_expect = 3
server           = true
client_addr      = "0.0.0.0"
