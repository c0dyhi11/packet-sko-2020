variable "api_key" {}
variable "project_id" {}

provider "packet" {
  auth_token          =   var.api_key
}

resource "tls_private_key" "my_tf_ssh_key" {
  algorithm           =   "RSA"
  rsa_bits            =   4096
}

resource "local_file" "my_tf_priv_key" {
    content           =   chomp(tls_private_key.my_tf_ssh_key.private_key_pem)
    filename          =   "my_tf_ssh_key"
    file_permission   =   "0400"
}

resource "packet_ssh_key" "my_tf_ssh_key" {
  name                =   "my_tf_ssh_key"
  public_key          =   chomp(tls_private_key.my_tf_ssh_key.public_key_openssh)
}

resource "packet_device" "my_tf_server" {
  depends_on          =   [packet_ssh_key.my_tf_ssh_key]
  count               =   1
  hostname            =   format("my-tf-server-%02d", count.index + 1)
  plan                =   "c3.medium.x86"
  facilities          =   ["dfw2"]
  operating_system    =   "centos_7"
  billing_cycle       =   "hourly"
  project_id          =   var.project_id
}

output "IP_Address" {
  value = packet_device.my_tf_server[*].access_public_ipv4
}
