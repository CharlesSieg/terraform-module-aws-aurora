###################################################################
# ROUTE 53: CREATE ENTRIES POINTING TO AURORA ENDPOINTS.
###################################################################

resource "aws_route53_record" "dns_rds_writer_a" {
  name     = "${var.environment}.db"
  provider = aws.dnsProvider
  type     = "A"
  zone_id  = var.zone_id

  alias {
    evaluate_target_health = false
    name                   = aws_rds_cluster.cluster.endpoint
    zone_id                = aws_rds_cluster.cluster.hosted_zone_id
  }
}

resource "aws_route53_record" "dns_rds_writer_aaaa" {
  name     = "${var.environment}.db"
  provider = aws.dnsProvider
  type     = "AAAA"
  zone_id  = var.zone_id

  alias {
    evaluate_target_health = false
    name                   = aws_rds_cluster.cluster.endpoint
    zone_id                = aws_rds_cluster.cluster.hosted_zone_id
  }
}

resource "aws_route53_record" "dns_rds_readonly_a" {
  name     = "${var.environment}.ro.db"
  provider = aws.dnsProvider
  type     = "A"
  zone_id  = var.zone_id

  alias {
    evaluate_target_health = false
    name                   = aws_rds_cluster.cluster.reader_endpoint
    zone_id                = aws_rds_cluster.cluster.hosted_zone_id
  }
}

resource "aws_route53_record" "dns_rds_readonly_aaaa" {
  name     = "${var.environment}.ro.db"
  provider = aws.dnsProvider
  type     = "AAAA"
  zone_id  = var.zone_id

  alias {
    evaluate_target_health = false
    name                   = aws_rds_cluster.cluster.reader_endpoint
    zone_id                = aws_rds_cluster.cluster.hosted_zone_id
  }
}
