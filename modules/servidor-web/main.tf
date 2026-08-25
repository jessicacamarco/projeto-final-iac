data "aws_ami" "amazon_linux" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

resource "aws_security_group" "web" {
  name   = "web-${var.ambiente}"
  vpc_id = var.vpc_id

  ingress {
    description = "SSH"

    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Aplicacao Docker"

    from_port = var.app_port
    to_port   = var.app_port
    protocol  = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name     = "sg-${var.ambiente}"
    Curso    = var.curso
    Ambiente = var.ambiente
  }
}

resource "aws_key_pair" "deployer" {
  key_name   = "projeto-final-iac-${var.ambiente}"
  public_key = file(pathexpand(var.public_key_path))
}

resource "aws_instance" "web" {

  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type

  subnet_id = var.subnet_id

  vpc_security_group_ids = [
    aws_security_group.web.id
  ]

  associate_public_ip_address = true

  key_name = aws_key_pair.deployer.key_name

  tags = {
    Name     = "web-${var.ambiente}"
    Curso    = var.curso
    Ambiente = var.ambiente
  }

}
