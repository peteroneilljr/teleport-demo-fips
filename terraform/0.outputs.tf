output teleport_cluster_ssh {
  value       = <<EOF
    ssh -i ${local_sensitive_file.ssh.filename} \
      -o UserKnownHostsFile=/dev/null \
      -o StrictHostKeyChecking=no \
      ec2-user@${aws_eip.cluster.public_ip}
  EOF
}
output teleport_cluster_fqdn {
  value       = "https://${aws_route53_record.cluster.fqdn}"
}
output teleport_tsh_login {
  value       = "tsh login --proxy=${var.teleport_cluster_name}.${var.aws_dns_route53_zone}:443 --auth=github"
}
output teleport_tunnel_dynomodb {
  value       = <<EOF
    AWS_REGION=${var.aws_gov_region} \
    AWS_USE_FIPS_ENDPOINT=true \
    tsh proxy db --tunnel --port 8000 --db-user=${aws_iam_role.teleport_assume_ro.id} dynamodb-backend
  EOF
}
output teleport_s3_fips {
  value       = <<EOF
    tsh apps login aws-console --aws-role ${aws_iam_role.teleport_assume_ro.id}

    AWS_REGION=${var.aws_gov_region} \
    AWS_USE_FIPS_ENDPOINT=true \
    tsh -d aws s3 ls
  EOF
}
output teleport_check_certificate {
  value       = <<EOF
    openssl s_client -connect "${var.teleport_cluster_name}.${var.aws_dns_route53_zone}:443" \
      -servername "${var.teleport_cluster_name}.${var.aws_dns_route53_zone}" -showcerts -status
  EOF
}
output teleport_startup_script {
  value       = local.teleport_user_data
  sensitive = true
}
