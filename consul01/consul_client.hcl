# /etc/consul.d/consul.hcl

node_name = "api" # "db"
data_dir = "/opt/consul"
bind_addr = "192.168.56.21" # "192.168.56.22"
client_addr = "0.0.0.0"
retry_join = ["192.168.56.20"]
ports {
  grpc = 8502
}
