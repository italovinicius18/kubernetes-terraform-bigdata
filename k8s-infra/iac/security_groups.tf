#EKS
resource "aws_security_group" "worker_group_mgmt_one" {
  name_prefix = local.worker_group_mgmt_one
  vpc_id      = var.vpc_id[terraform.workspace]
  #
  #  ingress {
  #    from_port   = 8080
  #    to_port     = 8080
  #    protocol    = "tcp"
  #    cidr_blocks = ["192.168.0.0/16"]
  #    description = "connection"
  #  }
  #
  #  ingress {
  #    from_port   = 8793
  #    to_port     = 8793
  #    protocol    = "tcp"
  #    cidr_blocks = ["192.168.0.0/16"]
  #    description = "connection"
  #  }
  #
  #  ingress {
  #    from_port   = 6379
  #    to_port     = 6379
  #    protocol    = "tcp"
  #    cidr_blocks = ["192.168.0.0/16"]
  #    description = "connection"
  #  }
  #
  #  ingress {
  #    from_port   = 9443
  #    to_port     = 9443
  #    protocol    = "tcp"
  #    cidr_blocks = ["192.168.0.0/16"]
  #    description = "connection"
  #  }
  #
  #  ingress {
  #    from_port = 22
  #    to_port   = 22
  #    protocol  = "tcp"
  #
  #    cidr_blocks = [
  #      "10.0.0.0/8",
  #      "172.16.0.0/12",
  #      "192.168.0.0/16",
  #    ]
  #  }
  #
  egress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # 192.168.0.0/22
  # 172.31.0.0/16
  # 172.30.0.0/16
  # 172.20.0.0/16

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # ingress {
  #   from_port = 0
  #   to_port   = 0
  #   protocol  = "-1"
  #   cidr_blocks = [
  #     "192.168.0.0/22",
  #     "172.31.0.0/16",
  #     "172.30.0.0/16",
  #     "172.20.0.0/16"
  #   ]
  # }


  # ingress {
  #   from_port   = 0
  #   to_port     = 0
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

}