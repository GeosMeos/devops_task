output "lamp_public_ip" {
  value = aws_instance.lamp.*.public_ip
}

output "windows_public_ip" {
  value = aws_instance.win_server_2019.public_ip
}

output "Administrator_Password" {
  value = rsadecrypt(aws_instance.win_server_2019.password_data, file(var.key_path))
}

output "lb_dns_name" {
  value = aws_elb.lb.dns_name
}