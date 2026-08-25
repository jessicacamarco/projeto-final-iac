variable "vpc_id" {
  description = "ID da VPC"
  type        = string
}

variable "subnet_id" {
  description = "ID da Subnet"
  type        = string
}

variable "app_port" {
  description = "Porta utilizada pela aplicação"
  type        = number
}

variable "instance_type" {
  description = "Tipo da instância"
  type        = string
}

variable "curso" {
  description = "Nome do curso"
  type        = string
}

variable "ambiente" {
  description = "Workspace atual"
  type        = string
}

variable "nome_aluno" {
  description = "Nome do aluno"
  type        = string
}

variable "turma" {
  description = "Turma"
  type        = string
}

variable "public_key_path" {
  description = "Caminho da chave pública SSH utilizada pela EC2"
  type        = string
}


