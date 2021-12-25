# hashicluster/vault - 00-agent.hcl
#
# General configuration for Vault agents.

storage "consul" {
  address = "127.0.0.1:8500"
  path    = "service/vault/storage"
}

# HTTP listener
listener "tcp" {
  address = "0.0.0.0:8200"
  tls_disable = 1
}

# # HTTPS listener
# listener "tcp" {
#   address       = "0.0.0.0:8200"
#   tls_cert_file = "/opt/vault/tls/tls.crt"
#   tls_key_file  = "/opt/vault/tls/tls.key"
# }
