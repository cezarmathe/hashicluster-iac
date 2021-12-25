# hashicluster/consul - 60-master.hcl
#
# Configuration for Consul on worker servers.

retry_join = [
  "provider=aws tag_key=HashiCluster/Name tag_value=sample",
]
