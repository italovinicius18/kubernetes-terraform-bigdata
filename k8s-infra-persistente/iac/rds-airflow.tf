resource "aws_subnet" "rds_subnet_airflow" {
  count                   = length(var.vpc_subnets_cidr[terraform.workspace]["airflow"])
  vpc_id                  = var.vpc_id[terraform.workspace]
  cidr_block              = var.vpc_subnets_cidr[terraform.workspace]["airflow"][count.index]
  availability_zone       = element(["us-east-1c", "us-east-1b"], count.index % 2)
  map_public_ip_on_launch = true
  tags = merge(local.common_tags, {
    "Name" = "rds-${terraform.workspace}-public-${count.index + 1}"
  })
}

resource "aws_db_subnet_group" "sn_group_rds_postgres" {
  name        = "rds-postgres-${terraform.workspace}"
  description = "Security group for RDS Postgres Airflow"
  subnet_ids  = aws_subnet.rds_subnet_airflow[*].id

  tags = merge(local.airflow_tags, {
    "Name" = "sn-group-rds-postgres-${terraform.workspace}"
  })
}


resource "aws_route_table_association" "eks_airflow_subnet_association" {
  count          = length(aws_subnet.rds_subnet_airflow[*].id)
  subnet_id      = aws_subnet.rds_subnet_airflow[count.index].id
  route_table_id = var.route_table_id[terraform.workspace]
}

resource "aws_security_group" "sg_rds_postgres" {
  name        = "rds-sg-postgres-airflow-${terraform.workspace}"
  description = "Security group for RDS Postgres Airflow"
  vpc_id      = var.vpc_id[terraform.workspace]

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = var.vpc_subnets_cidr[terraform.workspace]["public"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(local.airflow_tags, {
    "Name" = "sg-rds-postgres"
  })

}

data "aws_secretsmanager_secret" "airflow-database-credentials" {
  name = "${upper(terraform.workspace)}-RDS-POSTGRES-CREDENTIALS"
}

data "aws_secretsmanager_secret_version" "secret-airflow-database-credentials" {
  secret_id = data.aws_secretsmanager_secret.airflow-database-credentials.id
}

resource "aws_db_instance" "airflow" {
  identifier                   = "airflow-${terraform.workspace}"
  instance_class               = "db.t3.micro"
  allocated_storage            = 8
  storage_type                 = "gp2"
  engine                       = "postgres"
  engine_version               = "15.5"
  auto_minor_version_upgrade   = false
  db_name                      = "airflow"
  username                     = "postgres"
  password                     = jsondecode(data.aws_secretsmanager_secret_version.secret-airflow-database-credentials.secret_string)["password"]
  db_subnet_group_name         = aws_db_subnet_group.sn_group_rds_postgres.name
  vpc_security_group_ids       = aws_security_group.sg_rds_postgres[*].id
  backup_retention_period      = 1
  deletion_protection          = false
  skip_final_snapshot          = true
  publicly_accessible          = false
  performance_insights_enabled = true

  tags = merge(local.airflow_tags, {
    "Name" = "rds-airflow-${terraform.workspace}"
  })
}