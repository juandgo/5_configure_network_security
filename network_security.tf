locals {
  common_tags = {
    Project = var.project_id
  }
}

# ------------------------------------------------------------------------------
# 1. Fetch EC2 Instance Data
# ------------------------------------------------------------------------------
data "aws_instance" "public" {
  instance_id = var.public_instance_id
}

data "aws_instance" "private" {
  instance_id = var.private_instance_id
}

# ------------------------------------------------------------------------------
# 2. SSH Security Group
# ------------------------------------------------------------------------------
resource "aws_security_group" "ssh" {
  name        = "${var.project_id}-ssh-sg"
  description = "Allow SSH and ICMP access from allowed IP ranges"
  vpc_id      = var.vpc_id

  tags = merge(local.common_tags, {
    Name = "${var.project_id}-ssh-sg"
  })
}

resource "aws_security_group_rule" "ssh_ingress_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = var.allowed_ip_range
  security_group_id = aws_security_group.ssh.id
}

resource "aws_security_group_rule" "ssh_ingress_icmp" {
  type              = "ingress"
  from_port         = -1
  to_port           = -1
  protocol          = "icmp"
  cidr_blocks       = var.allowed_ip_range
  security_group_id = aws_security_group.ssh.id
}

# ------------------------------------------------------------------------------
# 3. Public HTTP Security Group
# ------------------------------------------------------------------------------
resource "aws_security_group" "public_http" {
  name        = "${var.project_id}-public-http-sg"
  description = "Allow HTTP and ICMP access from allowed IP ranges"
  vpc_id      = var.vpc_id

  tags = merge(local.common_tags, {
    Name = "${var.project_id}-public-http-sg"
  })
}

resource "aws_security_group_rule" "public_http_ingress_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = var.allowed_ip_range
  security_group_id = aws_security_group.public_http.id
}

resource "aws_security_group_rule" "public_http_ingress_icmp" {
  type              = "ingress"
  from_port         = -1
  to_port           = -1
  protocol          = "icmp"
  cidr_blocks       = var.allowed_ip_range
  security_group_id = aws_security_group.public_http.id
}

# ------------------------------------------------------------------------------
# 4. Private HTTP Security Group
# ------------------------------------------------------------------------------
resource "aws_security_group" "private_http" {
  name        = "${var.project_id}-private-http-sg"
  description = "Allow HTTP (8080) and ICMP access only from Public HTTP Security Group"
  vpc_id      = var.vpc_id

  tags = merge(local.common_tags, {
    Name = "${var.project_id}-private-http-sg"
  })
}

resource "aws_security_group_rule" "private_http_ingress_http" {
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.public_http.id
  security_group_id        = aws_security_group.private_http.id
}

resource "aws_security_group_rule" "private_http_ingress_icmp" {
  type                     = "ingress"
  from_port                = -1
  to_port                  = -1
  protocol                 = "icmp"
  source_security_group_id = aws_security_group.public_http.id
  security_group_id        = aws_security_group.private_http.id
}

# ------------------------------------------------------------------------------
# 5. Security Group Attachments
# ------------------------------------------------------------------------------
resource "aws_network_interface_sg_attachment" "public_ssh" {
  security_group_id    = aws_security_group.ssh.id
  network_interface_id = data.aws_instance.public.network_interface_id
}

resource "aws_network_interface_sg_attachment" "public_http" {
  security_group_id    = aws_security_group.public_http.id
  network_interface_id = data.aws_instance.public.network_interface_id
}

resource "aws_network_interface_sg_attachment" "private_ssh" {
  security_group_id    = aws_security_group.ssh.id
  network_interface_id = data.aws_instance.private.network_interface_id
}

resource "aws_network_interface_sg_attachment" "private_http" {
  security_group_id    = aws_security_group.private_http.id
  network_interface_id = data.aws_instance.private.network_interface_id
}