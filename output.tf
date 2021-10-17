output "id" {
  value = aws_vpc.Prod-iTS-Apps-VPC.id
}
output "public_ip" {
  value = aws_instance.webserver.public_ip
}
output "private_ip" {
  value = aws_instance.dbserver.private_ip
}
output "instance-id" {
  value = aws_instance.webserver.id
}
