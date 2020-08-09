output "web_server_ip" {
  value = aws_eip.awesome_eip.public_ip
}