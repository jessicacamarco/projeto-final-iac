resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name     = "vpc-${terraform.workspace}"
    Curso    = "IAC"
    Ambiente = terraform.workspace
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name     = "subnet-public-${terraform.workspace}"
    Curso    = "IAC"
    Ambiente = terraform.workspace
  }
}
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name     = "igw-${terraform.workspace}"
    Curso    = "IAC"
    Ambiente = terraform.workspace
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name     = "rt-public-${terraform.workspace}"
    Curso    = "IAC"
    Ambiente = terraform.workspace
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

module "servidor_web" {

  source = "./modules/servidor-web"

  vpc_id    = aws_vpc.main.id
  subnet_id = aws_subnet.public.id

  app_port = var.app_port

  instance_type = terraform.workspace == "prod" ? var.instance_type_prod : var.instance_type_dev

  public_key_path = var.public_key_path

  curso      = var.curso
  ambiente   = terraform.workspace
  nome_aluno = var.nome_aluno
  turma      = var.turma
}
