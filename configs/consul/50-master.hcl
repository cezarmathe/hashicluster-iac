# hashicluster/consul - 50-master.hcl
#
# Configuration for Consul on master servers.

ui_config{
  enabled = true
}

retry_join = [
  "provider=aws tag_key=HashiCluster/Name tag_value=sample",
]
