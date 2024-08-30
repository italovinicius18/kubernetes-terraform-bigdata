resource "aws_subnet" "eks_subnet_public" {
  count                   = length(var.vpc_subnets_cidr[terraform.workspace]["public"])
  vpc_id                  = var.vpc_id[terraform.workspace]
  cidr_block              = var.vpc_subnets_cidr[terraform.workspace]["public"][count.index]
  availability_zone       = element(["us-east-1c", "us-east-1b"], count.index % 2)
  map_public_ip_on_launch = true
  tags = merge(local.common_tags, {
    "Name"                                        = "eks-${terraform.workspace}-public-${count.index + 1}"
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  })
}

# Associate the public subnets with the route table
resource "aws_route_table_association" "eks_public_subnet_association" {
  count          = length(aws_subnet.eks_subnet_public[*].id)
  subnet_id      = aws_subnet.eks_subnet_public[count.index].id
  route_table_id = var.route_table_id[terraform.workspace]
}