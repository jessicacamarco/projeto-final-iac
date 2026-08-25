variable "aws_region" {
  description = "Região da AWS"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR da VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR da Subnet Pública"
  type        = string
  default     = "10.0.1.0/24"
}

variable "app_port" {
  description = "Porta utilizada pela aplicação"
  type        = number
  default     = 3000
}

variable "curso" {
  description = "Nome do curso"
  type        = string
  default     = "Pós Graduação DevOps"
}

variable "nome_aluno" {
  description = "Nome do aluno"
  type        = string
  default     = "Jessica Camarço"
}

variable "turma" {
  description = "Turma"
  type        = string
  default     = "IAC"
}

variable "instance_type_dev" {
  description = "Tipo da instância para DEV"
  type        = string
  default     = "t3.micro"
}

variable "instance_type_prod" {
  description = "Tipo da instância para PROD"
  type        = string
  default     = "t3.micro"
}

variable "public_key_path" {
  description = "Caminho da chave pública SSH utilizada pela EC2"
  type        = string
  default     = "~/.ssh/projeto-final-iac.pub"
}
