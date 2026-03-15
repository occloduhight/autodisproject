data "aws_ami" "rhel_9" {
  most_recent = true
  owners      = ["309956199498"]

  filter {
    name   = "name"
    values = ["RHEL-9*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

# IAM role for EC2 instances (Nexus) to access SSM
resource "aws_iam_role" "nexus_ssm_role" {
  name = "${var.name}-nexus-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = { Service = "ec2.amazonaws.com" },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "nexus_ssm_managed" {
  role       = aws_iam_role.nexus_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "nexus_instance_profile" {
  name = "${var.name}-nexus-instance-profile"
  role = aws_iam_role.nexus_ssm_role.name
}

resource "aws_security_group" "nexus_sg" {
  name        = "${var.name}-nexus-sg"
  description = "Nexus server security group"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow all IPs (for practice only)"
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    security_groups = [aws_security_group.nexus_elb_sg.id]
  }

  ingress {
    description     = "Nexus app from ELB"
    from_port       = 8085
    to_port         = 8085
    protocol        = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.name}-nexus-sg" }
}

# Security Groups
resource "aws_security_group" "nexus_elb_sg" {
  name        = "${var.name}-nexus-elb-sg"
  description = "ELB for Nexus (HTTPS)"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.name}-nexus-elb-sg" }
}

# Nexus EC2 instance
resource "aws_instance" "nexus" {
  ami                         = data.aws_ami.rhel_9.id
  instance_type               = "t2.large"
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.nexus_sg.id]
  iam_instance_profile        = aws_iam_instance_profile.nexus_instance_profile.name
  associate_public_ip_address = true
  key_name                    = var.key_name

  user_data = templatefile("${path.module}/nexus.sh", {
    newrelic_api_key     = var.newrelic_api_key,
    newrelic_account_id = var.newrelic_account_id
  })

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
    encrypted   = true
  }

  tags = { Name = "${var.name}-nexus" }
}

resource "aws_acm_certificate" "nexus_cert" {
  domain_name       = "nexus.odochidevops.space"
  validation_method = "DNS"
}
# Classic ELB for Nexus
resource "aws_elb" "nexus_elb" {
  name            = "${var.name}-nexus-elb"
  subnets         = var.subnet_ids
  security_groups = [aws_security_group.nexus_elb_sg.id]

  listener {
    lb_port           = 443
    lb_protocol       = "https"
    instance_port     = 8081
    instance_protocol = "http"
    ssl_certificate_id = data.aws_acm_certificate.acm-cert.arn
  
  }
  health_check {
    target              = "HTTP:8081/"
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
}
  instances = [aws_instance.nexus.id]
  tags      = { Name = "${var.name}-nexus-elb" }
}

# Route53 Record for Nexus
data "aws_route53_zone" "my_hosted_zone" {
  name         = var.domain_name
  private_zone = false
}

# data block to fetch ACM certificate for Nexus
data "aws_acm_certificate" "acm-cert" {
  domain      = "*.odochidevops.space"
  statuses    = ["ISSUED"]
  most_recent = true
}

# Route53 Record for Nexus Service
resource "aws_route53_record" "nexus_dns" {
  zone_id = data.aws_route53_zone.my_hosted_zone.zone_id
  name    = "nexus.${var.domain_name}"
  type    = "A"

  alias {
    name                   = aws_elb.nexus_elb.dns_name
    zone_id                = aws_elb.nexus_elb.zone_id
    evaluate_target_health = true
  }
}
