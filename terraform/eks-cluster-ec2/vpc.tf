# we need to create the AWS VPC itself. Here it's very important to enable dns support 
# and hostnames, especially if you are planning to use the EFS file system in your cluster. 
# Otherwise, the CSI driver will fail to resolve the EFS endpoint. Currently, 
# AWS Fargate does not support EBS volumes, so EFS is the only option for you if you want to run 
# stateful workloads in your Kubernetes cluster.

# Create a vpc resouce
resource "aws_vpc" "main" {
  cidr_block = "10.20.0.0/16"

  # Must be enabled for EFS
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "main"
  }
}


## Create an IGW. It is used to provide internet access directly from the public subnets 
# and indirectly from private subnets by using a NAT gateway.

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "igw"
  }
}


# Now we need to create four subnets. Two private subnets and two public subnets. 
# If you are using a different region, you need to update availability zones. Also, 
# it's very important to tag your subnets with the following labels. 
# Internal-elb tag used by EKS to select subnets to create private load balancers and elb tag for public load balancers. 
# Also, you need to have a cluster tag with owned or shared value.

resource "aws_subnet" "private-us-east-1a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.20.0.0/24"
  availability_zone = "us-east-1a"

  tags = {
    "Name"                                      = "private-us-east-1a"
    "kubernetes.io/role/internal-elb"           = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}

resource "aws_subnet" "private-us-east-1b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.20.32.0/24"
  availability_zone = "us-east-1b"

  tags = {
    "Name"                                      = "private-us-east-1b"
    "kubernetes.io/role/internal-elb"           = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}

resource "aws_subnet" "public-us-east-1a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.20.64.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    "Name"                                      = "public-us-east-1a"
    "kubernetes.io/role/elb"                    = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}

resource "aws_subnet" "public-us-east-1b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.20.96.0/20"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    "Name"                                      = "public-us-east-1b"
    "kubernetes.io/role/elb"                    = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}


resource "aws_eip" "nat" {
  vpc = true

  tags = {
    Name = "nat"
  }
}

# Create a NAT gateway

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public-us-east-1a.id

  tags = {
    Name = "nat"
  }

  depends_on = [aws_internet_gateway.igw]
}



# The last components that we need to create before we can start provisioning EKS are route tables.
# The first is the private route table with the default route to the NAT Gateway. 
# The second is a public route table with the default route to the Internet Gateway. 
# Finally, we need to associate previously created subnets with these route tables. 
# Two private subnets and two public subnets.

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "private"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public"
  }
}

resource "aws_route_table_association" "private-us-east-1a" {
  subnet_id      = aws_subnet.private-us-east-1a.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private-us-east-1b" {
  subnet_id      = aws_subnet.private-us-east-1b.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "public-us-east-1a" {
  subnet_id      = aws_subnet.public-us-east-1a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public-us-east-1b" {
  subnet_id      = aws_subnet.public-us-east-1b.id
  route_table_id = aws_route_table.public.id
}
