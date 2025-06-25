node_name = "consulserver"
server = true
bootstrap_expect = 1
data_dir = "/opt/consul"
bind_addr = "192.168.56.20"
client_addr = "0.0.0.0"
ui = true
connect {
  enabled = true
}
ports {
  grpc = 8502
}
retry_join = ["192.168.56.20"]
