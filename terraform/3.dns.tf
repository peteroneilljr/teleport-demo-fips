resource "aws_eip" "cluster" {
  instance = aws_instance.cluster.id
  domain   = "vpc"
}

data "aws_route53_zone" "cluster" {
  provider = aws.dns
  
  name = var.aws_dns_route53_zone
}

# ---------------------------------------------------------------------------- #
# Create DNS records
# ---------------------------------------------------------------------------- #
resource "aws_route53_record" "cluster" {
  provider = aws.dns

  zone_id = data.aws_route53_zone.cluster.zone_id
  name    = var.teleport_cluster_name
  type    = "A"
  ttl     = 300
  records = [aws_eip.cluster.public_ip]
}

resource "aws_route53_record" "wildcard-cluster" {
  provider = aws.dns

  zone_id = data.aws_route53_zone.cluster.zone_id
  name    = "*.${var.teleport_cluster_name}"
  type    = "A"
  ttl     = 300
  records = [aws_eip.cluster.public_ip]
}
