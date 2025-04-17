resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
resource "aws_key_pair" "ssh" {
  key_name_prefix = var.aws_gov_region
  public_key      = tls_private_key.ssh.public_key_openssh
}
resource "local_sensitive_file" "ssh" {
  content  = tls_private_key.ssh.private_key_pem
  filename = "${path.module}/${aws_key_pair.ssh.key_name}.pem"
}