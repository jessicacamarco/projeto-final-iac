# Projeto Final - Infraestrutura como Código (IaC) com Terraform e Ansible

## Objetivo

Este projeto foi desenvolvido como parte da disciplina de **Infraestrutura como Código (IaC)** da Pós-graduação em DevOps.

O objetivo é demonstrar, de forma prática, a integração entre **Terraform** e **Ansible** para provisionamento e configuração automatizada de uma infraestrutura na AWS.

O **Terraform** é responsável pelo provisionamento da infraestrutura na AWS, incluindo:

- VPC;
- Subnet pública;
- Internet Gateway;
- Route Table;
- Security Group;
- Key Pair;
- Instância EC2;
- Backend remoto para armazenamento do Terraform State.

Após o provisionamento, o **Ansible** é utilizado para realizar a configuração da instância EC2, incluindo:

- descoberta dinâmica da instância AWS;
- conexão via SSH;
- instalação do Docker Engine;
- garantia de execução do serviço Docker;
- download da imagem da aplicação;
- criação e execução do container;
- publicação da aplicação na porta 3000;
- validação do container;
- utilização do Ansible Vault para proteção de variável sensível;
- execução idempotente das configurações.

A aplicação utilizada no projeto é a `getting-started-app`, executada como container Docker.

---

## Arquitetura da Solução

A solução foi dividida em duas etapas principais:

1. **Terraform:** responsável pelo provisionamento da infraestrutura AWS;
2. **Ansible:** responsável pela configuração da instância EC2 e execução da aplicação.

### Arquitetura atual

```text
                              INTERNET
                                  |
                                  |
                                  v
                       +-------------------+
                       | Internet Gateway  |
                       +-------------------+
                                  |
                                  v
                 +--------------------------------+
                 |              VPC                 |
                 |                                  |
                 |          10.0.0.0/16             |
                 |                                  |
                 |   +--------------------------+   |
                 |   |     Subnet Pública       |   |
                 |   |       us-east-1a         |   |
                 |   |                          |   |
                 |   |   +------------------+   |   |
                 |   |   | Security Group   |   |   |
                 |   |   |                  |   |   |
                 |   |   | SSH       :22    |   |   |
                 |   |   | Aplicação :3000  |   |   |
                 |   |   +--------+---------+   |   |
                 |   |            |             |   |
                 |   |            v             |   |
                 |   |   +------------------+  |   |
                 |   |   | EC2 - t3.micro   |  |   |
                 |   |   |                  |  |   |
                 |   |   | Docker           |  |   |
                 |   |   | getting-started  |  |   |
                 |   |   | :80 -> :3000     |  |   |
                 |   |   +------------------+  |   |
                 |   +--------------------------+   |
                 +--------------------------------+

                         TERRAFORM
                             |
                             v
                     Provisionamento AWS
                             |
                             v
                          ANSIBLE
                             |
                             v
                  Configuração da EC2
                             |
                             v
                         DOCKER
                             |
                             v
                   getting-started-app
```

### Fluxo de execução

```text
Terraform
   |
   +--> VPC
   |
   +--> Subnet Pública
   |
   +--> Internet Gateway
   |
   +--> Route Table
   |
   +--> Security Group
   |
   +--> Key Pair
   |
   +--> EC2
          |
          v
       Ansible
          |
          +--> Dynamic Inventory AWS
          |
          +--> SSH
          |
          +--> Docker Engine
          |
          +--> Container
          |
          +--> Aplicação
                 |
                 v
              Porta 3000
```

---

# Estrutura do Projeto

A estrutura final do projeto é organizada da seguinte forma:

```text
projeto-final-iac/
│
├── ansible/
│   ├── ansible.cfg
│   ├── inventory.aws_ec2.yml
│   ├── playbook.yml
│   ├── verificar-container.yml
│   └── group_vars/
│       └── all/
│           └── vault.yml
│
├── bootstrap/
│   └── main.tf
│
├── modules/
│   └── servidor-web/
│       ├── main.tf
│       ├── outputs.tf
│       └── variables.tf
│
├── images/
│   ├── terraform_*.png
│   └── ansible_*.png
│
├── backend.tf
├── main.tf
├── outputs.tf
├── provider.tf
├── README.md
├── terraform.tfvars
├── variables.tf
├── versions.tf
└── .gitignore
```

---

# Responsabilidade dos arquivos Terraform

## `versions.tf`

Define a versão mínima do Terraform e os requisitos dos providers utilizados pelo projeto.

---

## `provider.tf`

Responsável pela configuração do provider AWS utilizado pelo Terraform.

A região utilizada no projeto é:

```text
us-east-1
```

---

## `backend.tf`

Configura o armazenamento remoto do Terraform State utilizando um bucket Amazon S3.

O armazenamento remoto permite que o estado da infraestrutura seja mantido fora da máquina local utilizada para execução do Terraform.

---

## `variables.tf`

Define as variáveis utilizadas pelo projeto, incluindo informações relacionadas à:

- VPC;
- subnet;
- portas;
- tipos de instância;
- informações acadêmicas;
- chave pública SSH.

---

## `terraform.tfvars`

Arquivo utilizado para fornecer valores específicos do ambiente.

Exemplo:

```hcl
ssh_ip = "SEU_IP_PUBLICO/32"
```

Este arquivo não deve ser versionado no Git, pois contém configurações específicas do ambiente.

---

## `main.tf`

Arquivo principal da infraestrutura.

Responsável pela criação de:

- VPC;
- Subnet pública;
- Internet Gateway;
- Route Table;
- associação da Route Table com a Subnet;
- chamada do módulo responsável pela instância EC2.

---

## `outputs.tf`

Define os valores disponibilizados após o provisionamento.

Os principais outputs são:

```text
public_ip
public_dns
```

---

# Módulo `servidor-web`

O módulo localizado em:

```text
modules/servidor-web/
```

é responsável pela configuração da instância web.

### `modules/servidor-web/main.tf`

Responsável por:

- consulta da AMI Amazon Linux mais recente;
- criação do Security Group;
- criação do Key Pair;
- criação da instância EC2.

A AMI é obtida dinamicamente utilizando:

```hcl
data "aws_ami" "amazon_linux" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}
```

Dessa forma, o projeto não depende de um ID de AMI fixo.

---

# Bootstrap e Backend remoto

O projeto utiliza um bucket Amazon S3 para armazenamento remoto do Terraform State.

Para evitar a criação manual do bucket, foi criada uma etapa de bootstrap separada.

## Diretório

```text
bootstrap/
└── main.tf
```

## Execução

A partir da raiz do projeto:

```bash
cd bootstrap
terraform init
terraform plan
terraform apply
```

Após a criação do bucket, retornar para a raiz:

```bash
cd ..
```

E inicializar o Terraform principal:

```bash
terraform init
```

---

# Pré-requisitos

Antes de executar o projeto, é necessário possuir:

- Conta AWS;
- AWS CLI instalada;
- Terraform 1.5 ou superior;
- Ansible instalado;
- Git;
- Python;
- acesso SSH;
- credenciais AWS válidas.

Também é necessário possuir uma chave SSH para acesso à instância EC2.

Exemplo:

```text
~/.ssh/projeto-final-iac
~/.ssh/projeto-final-iac.pub
```

As credenciais AWS utilizadas no laboratório são temporárias e devem estar válidas durante a execução.

**Nenhuma credencial AWS deve ser armazenada ou versionada no repositório.**

---

# Passo a passo - Terraform

## Passo 1 - Configurar as credenciais AWS

Configure as credenciais utilizando a AWS CLI:

```bash
aws configure
```

Informe:

```text
AWS Access Key ID
AWS Secret Access Key
Default region name: us-east-1
Default output format: json
```

Em ambientes de laboratório, como AWS Academy, as credenciais podem ser temporárias.

Nesse caso, é necessário atualizar as credenciais sempre que um novo laboratório for iniciado.

Verifique a configuração:

```bash
aws configure list
```

---

## Passo 2 - Validar acesso à AWS

Antes de executar o Terraform, é recomendável validar se a AWS CLI consegue acessar a conta:

```bash
aws sts get-caller-identity
```

Se o comando retornar as informações da identidade AWS, as credenciais estão funcionando.

---

## Passo 3 - Executar o Bootstrap

Entrar no diretório:

```bash
cd bootstrap
```

Inicializar:

```bash
terraform init
```

Verificar o plano:

```bash
terraform plan
```

Aplicar:

```bash
terraform apply
```

Após a criação do bucket:

```bash
cd ..
```

---

## Passo 4 - Inicializar o Terraform principal

Na raiz do projeto:

```bash
terraform init
```

O comando inicializa:

- backend remoto;
- provider AWS;
- módulos Terraform.

---

## Passo 5 - Formatar os arquivos

Execute:

```bash
terraform fmt -recursive
```

---

## Passo 6 - Validar a configuração

Execute:

```bash
terraform validate
```

O resultado esperado é:

```text
Success! The configuration is valid.
```

---

## Passo 7 - Criar o workspace DEV

Criar:

```bash
terraform workspace new dev
```

Selecionar:

```bash
terraform workspace select dev
```

Verificar:

```bash
terraform workspace show
```

O resultado esperado:

```text
dev
```

---

## Passo 8 - Provisionar o ambiente DEV

Executar o planejamento:

```bash
terraform plan
```

Se não houver problemas:

```bash
terraform apply
```

Após a conclusão:

```bash
terraform output
```

Serão apresentados:

```text
public_dns
public_ip
```

Esses valores serão utilizados posteriormente para validação e acesso à aplicação.

---

# Ambientes Terraform

O projeto utiliza Terraform Workspaces para separar os ambientes.

## DEV

```bash
terraform workspace select dev
terraform apply
```

O ambiente DEV utiliza o tipo de instância definido pela variável `instance_type_dev`.

## PROD

Criar:

```bash
terraform workspace new prod
```

Selecionar:

```bash
terraform workspace select prod
```

Executar:

```bash
terraform apply
```

O ambiente PROD utiliza o tipo de instância definido pela variável `instance_type_prod`.

A seleção do tipo de instância é realizada no módulo por meio do workspace:

```hcl
instance_type = terraform.workspace == "prod" ? var.instance_type_prod : var.instance_type_dev
```

---

# Key Pair SSH

O projeto utiliza um Key Pair gerenciado pelo Terraform.

A chave pública local é informada por meio da variável:

```hcl
public_key_path
```

Exemplo:

```text
~/.ssh/projeto-final-iac.pub
```

O Terraform cria o Key Pair na AWS:

```hcl
resource "aws_key_pair" "deployer" {
  key_name   = "projeto-final-iac-${var.ambiente}"
  public_key = file(pathexpand(var.public_key_path))
}
```

A chave privada permanece somente na máquina responsável pelo acesso.

---

# Passo a passo - Ansible

Após o provisionamento da EC2, a configuração da máquina passa a ser realizada pelo Ansible.

Entrar no diretório:

```bash
cd ansible
```

**Os comandos Ansible deste projeto devem ser executados a partir desse diretório**, pois o arquivo `ansible.cfg` e o inventário estão organizados nessa estrutura.

---

# Inventário dinâmico AWS

O projeto utiliza o plugin de inventário dinâmico da AWS.

Arquivo:

```text
ansible/inventory.aws_ec2.yml
```

O inventário consulta diretamente a AWS para localizar a instância `web-dev` em execução.

Isso evita a necessidade de manter manualmente o endereço IP da EC2 no inventário.

Validar o inventário:

```bash
ansible-inventory -i inventory.aws_ec2.yml --graph
```

Também é possível listar o inventário:

```bash
ansible-inventory -i inventory.aws_ec2.yml --list
```

---

# Validação do inventário

Antes de executar o playbook, é importante confirmar se o Ansible consegue localizar a instância.

Exemplo:

```bash
ansible-inventory -i inventory.aws_ec2.yml --graph
```

A instância deve aparecer no inventário.

Durante a implementação, foi identificado que executar os comandos a partir da raiz do projeto fazia o Ansible não localizar corretamente o inventário e sua configuração.

O problema era indicado por mensagens como:

```text
No inventory was parsed
```

e:

```text
only implicit localhost is available
```

A solução foi executar os comandos dentro do diretório:

```bash
cd ~/projeto-final-iac/ansible
```

Essa organização é importante para a reprodução do projeto.

---

# Teste de conectividade Ansible

Com o inventário funcionando:

```bash
ansible all -m ping
```

Resultado esperado:

```text
SUCCESS
```

Exemplo:

```text
3.88.214.212 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

O aviso relacionado à descoberta do interpretador Python na EC2 não impede a execução do projeto.

---

# Playbook principal

O arquivo:

```text
ansible/playbook.yml
```

é responsável pela configuração da instância.

As principais tarefas são:

1. Gathering Facts;
2. instalação do Docker Engine;
3. garantia de execução do Docker;
4. download da imagem da aplicação;
5. execução do container.

Executar:

```bash
ansible-playbook playbook.yml
```

---

# Idempotência do Ansible

Uma das características importantes do Ansible é a idempotência.

Após a primeira execução, uma segunda execução do mesmo playbook deve evitar alterações desnecessárias.

Executar novamente:

```bash
ansible-playbook playbook.yml
```

O resultado esperado é:

```text
changed=0
```

Isso demonstra que o estado desejado já foi alcançado e que o Ansible não precisa realizar novas alterações.

---

# Configuração do Docker

O playbook instala o Docker Engine e garante que o serviço esteja em execução.

Posteriormente, realiza o download da imagem:

```text
docker/getting-started:latest
```

E cria o container:

```text
getting-started-app
```

---

# Mapeamento de portas

Durante a validação inicial, foi utilizado o mapeamento:

```yaml
published_ports:
  - "3000:3000"
```

A aplicação, entretanto, estava atendendo internamente na porta 80.

Após os testes internos, o mapeamento foi ajustado para:

```yaml
published_ports:
  - "3000:80"
```

O resultado final é:

```text
EC2 :3000
     |
     v
Docker Container :80
     |
     v
Nginx
     |
     v
getting-started-app
```

Dessa forma, a aplicação permanece disponível externamente na porta 3000, conforme definido no projeto.

---

# Validação do container

Foi criado um playbook específico para validação:

```text
ansible/verificar-container.yml
```

Esse playbook consulta o container utilizando:

```text
community.docker.docker_container_info
```

e apresenta informações principais como:

- nome do container;
- imagem;
- status;
- estado de execução;
- porta publicada.

Executar:

```bash
ansible-playbook verificar-container.yml
```

Essa etapa foi criada como uma validação adicional do ambiente, permitindo verificar o estado do container de maneira automatizada.

---

# Validação interna da aplicação

Após a correção do mapeamento de portas, foi utilizada a seguinte validação:

```bash
ansible all -m ansible.builtin.uri -a "url=http://127.0.0.1:3000 status_code=200 timeout=5"
```

O resultado esperado é:

```text
status: 200
```

Esse teste comprova que a aplicação está respondendo dentro da própria EC2.

---

# Validação externa da aplicação

Após confirmar o funcionamento interno, a aplicação foi validada externamente:

```bash
curl -I --connect-timeout 5 --max-time 10 http://$(terraform output -raw public_ip):3000
```

O resultado esperado é:

```text
HTTP/1.1 200 OK
```

Esse teste comprova o funcionamento do caminho:

```text
Internet
   |
   v
IP público da EC2
   |
   v
Security Group - TCP 3000
   |
   v
EC2
   |
   v
Docker
   |
   v
Container :80
   |
   v
Aplicação
```

Também foi realizada validação visual pelo navegador:

```text
http://IP_PUBLICO:3000
```

---

# Ansible Vault

Para demonstrar o armazenamento seguro de uma variável sensível, foi utilizado o Ansible Vault.

Criar o diretório:

```bash
mkdir -p group_vars/all
```

Criar o arquivo criptografado:

```bash
ansible-vault create group_vars/all/vault.yml
```

Foi utilizada uma variável de exemplo:

```yaml
vault_app_secret: "segredo-simulado-projeto-final-iac"
```

O arquivo é armazenado de forma criptografada.

Para verificar:

```bash
cat group_vars/all/vault.yml
```

O conteúdo deve começar com algo semelhante a:

```text
$ANSIBLE_VAULT;1.1;AES256
```

A variável protegida é utilizada pelo playbook:

```yaml
env:
  APP_SECRET: "{{ vault_app_secret }}"
```

Dessa forma, o valor sensível não fica exposto diretamente no playbook.

---

# Execução do playbook com Vault

Executar:

```bash
ansible-playbook playbook.yml --ask-vault-pass
```

O Ansible solicitará a senha do Vault:

```text
Vault password:
```

Na primeira execução após a inclusão da variável protegida, o container foi alterado para incorporar a nova configuração.

Esse comportamento é esperado:

```text
changed=1
```

Em seguida, o mesmo playbook foi executado novamente:

```bash
ansible-playbook playbook.yml --ask-vault-pass
```

A segunda execução apresentou:

```text
changed=0
```

Esse resultado comprova novamente a idempotência do playbook, agora considerando também a configuração protegida pelo Vault.

---

# Troubleshooting e dificuldades encontradas

Durante a implementação foram identificados alguns problemas reais de ambiente e configuração. Os problemas foram investigados e solucionados durante a execução.

## 1. Credenciais AWS temporárias

Por se tratar de um ambiente de laboratório, as credenciais AWS são temporárias.

Ao iniciar uma nova sessão do laboratório, foi necessário atualizar as credenciais utilizadas pela AWS CLI.

Validação:

```bash
aws configure list
```

Também foi utilizada:

```bash
aws sts get-caller-identity
```

para confirmar a identidade ativa.

---

## 2. Alteração da Availability Zone da Subnet

Durante uma execução do Terraform foi identificada uma diferença entre a Availability Zone registrada anteriormente e a definida no projeto.

O Terraform apresentou uma substituição da subnet:

```text
availability_zone = "us-east-1e" -> "us-east-1a"
```

Como a Availability Zone faz parte da configuração da subnet, a alteração exigiu a substituição do recurso.

A configuração final utilizada foi:

```hcl
availability_zone = "us-east-1a"
```

---

## 3. Alteração dinâmica da AMI

A consulta da AMI foi configurada de forma dinâmica:

```hcl
data "aws_ami" "amazon_linux" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}
```

Durante uma nova execução, uma AMI diferente foi identificada.

Como a AMI faz parte da configuração da EC2, o Terraform apresentou:

```text
must be replaced
```

A alteração foi aceita como comportamento esperado da infraestrutura, sem fixar artificialmente um ID antigo de AMI.

---

## 4. Erro de variável não declarada

Durante a implementação do Key Pair, o Terraform apresentou:

```text
Reference to undeclared input variable
```

A causa foi a utilização de:

```hcl
var.public_key_path
```

sem que a variável tivesse sido declarada no módulo.

A variável foi adicionada em:

```text
modules/servidor-web/variables.tf
```

com:

```hcl
variable "public_key_path" {
  description = "Caminho da chave pública SSH utilizada pela EC2"
  type        = string
}
```

Também foi necessário passar a variável do módulo principal:

```hcl
public_key_path = var.public_key_path
```

Após salvar os arquivos, a validação passou normalmente.

Esse problema também reforçou a importância de salvar as alterações no editor antes de executar o Terraform.

---

## 5. KeyName ausente inicialmente

Ao consultar a EC2 com:

```bash
aws ec2 describe-instances \
  --instance-ids ID_DA_INSTANCIA \
  --query 'Reservations[].Instances[].KeyName' \
  --output text
```

não foi retornado um KeyName.

Isso ocorreu porque o Key Pair ainda não fazia parte da configuração da instância.

Posteriormente foi criado no Terraform:

```hcl
resource "aws_key_pair" "deployer" {
  key_name   = "projeto-final-iac-${var.ambiente}"
  public_key = file(pathexpand(var.public_key_path))
}
```

Após a aplicação:

```bash
aws ec2 describe-key-pairs \
  --key-names projeto-final-iac-dev \
  --query 'KeyPairs[0].KeyName' \
  --output text
```

retornou:

```text
projeto-final-iac-dev
```

---

## 6. Execução do Ansible no diretório incorreto

Durante a validação, alguns comandos Ansible foram executados a partir da raiz do projeto.

Isso resultou em mensagens como:

```text
No inventory was parsed
```

e:

```text
only implicit localhost is available
```

O problema ocorreu porque a configuração e o inventário estão no diretório:

```text
ansible/
```

A execução correta deve ser realizada com:

```bash
cd ~/projeto-final-iac/ansible
```

---

## 7. Mapeamento inicial incorreto das portas Docker

Inicialmente foi utilizado:

```yaml
published_ports:
  - "3000:3000"
```

Os testes internos demonstraram que a aplicação não respondia corretamente.

Após a investigação, verificou-se que o serviço web do container atendia internamente na porta 80.

O mapeamento foi então corrigido para:

```yaml
published_ports:
  - "3000:80"
```

Após a alteração, o teste:

```bash
ansible all -m ansible.builtin.uri -a "url=http://127.0.0.1:3000 status_code=200 timeout=5"
```

retornou:

```text
status: 200
```

---

## 8. Timeout durante o acesso externo

Mesmo após a aplicação responder internamente, o teste externo inicialmente apresentou:

```text
Connection timed out
```

O primeiro diagnóstico foi verificar o Security Group.

A regra existente era:

```text
TCP
Porta: 3000
Origem: 0.0.0.0/0
```

Portanto, a porta estava liberada no Security Group.

Em seguida, foi consultada diretamente a AWS para verificar a instância em execução.

Foi identificado que o IP público atual era diferente daquele apresentado anteriormente pelo Terraform.

O Terraform detectou:

```text
Objects have changed outside of Terraform
```

e identificou a alteração:

```text
public_ip = "34.229.147.184" -> "3.88.214.212"
```

O acesso estava sendo testado no IP antigo.

Após a atualização do estado:

```bash
terraform apply -refresh-only
```

os outputs passaram a apresentar o IP atual:

```text
public_ip = "3.88.214.212"
```

O acesso externo passou a funcionar normalmente.

---

# Sincronização do Terraform State

Quando a infraestrutura real sofreu uma alteração de IP público, o Terraform detectou a diferença entre o State e a infraestrutura AWS.

O comando:

```bash
terraform plan
```

identificou:

```text
Objects have changed outside of Terraform
```

Para atualizar somente o State, sem alterar a infraestrutura:

```bash
terraform apply -refresh-only
```

Após isso:

```bash
terraform output
```

retornou os valores atuais:

```text
public_dns = "ec2-3-88-214-212.compute-1.amazonaws.com"
public_ip  = "3.88.214.212"
```

---

# Evidências

As evidências da implementação foram organizadas na pasta:

```text
images/
```

Principais evidências:

```text
ansible_01_ping_success.png
ansible_02_playbook_first_run.png
ansible_03_playbook_idempotent.png
ansible_04_docker_container.png
ansible_06_application_curl.png
ansible_07_application_browser.png
ansible_08_vault_encrypted.png
ansible_09_vault_first_run.png
ansible_10_vault_idempotent.png
ansible_11_application_curl_final.png
ansible_12_application_browser_final.png
```

Também foram registradas evidências relacionadas ao Terraform, incluindo:

- outputs;
- provisionamento da EC2;
- Security Group;
- Workspaces;
- atualização do State;
- execução e destruição dos recursos.

---

# Outputs

Após o provisionamento:

```bash
terraform output
```

disponibiliza:

```text
public_ip
public_dns
```

Esses valores são utilizados para acesso e validação da aplicação.

---

# Tecnologias utilizadas

- Terraform
- Ansible
- Ansible Vault
- AWS EC2
- AWS VPC
- AWS S3
- AWS Security Group
- AWS Internet Gateway
- AWS Route Table
- AWS Key Pair
- Amazon Linux 2023
- Docker Engine
- Docker
- Nginx
- `getting-started-app`
- AWS CLI
- Git

---

# Segurança

As credenciais AWS utilizadas durante o laboratório não foram armazenadas no repositório.

O arquivo:

```text
terraform.tfvars
```

é específico do ambiente e está incluído no `.gitignore`.

A chave privada SSH também permanece fora do repositório.

A variável sensível utilizada pelo Ansible é armazenada por meio do:

```text
Ansible Vault
```

O arquivo criptografado pode ser versionado, mas a senha utilizada para descriptografá-lo não deve ser armazenada no repositório.

---

# `.gitignore`

O projeto utiliza um `.gitignore` para evitar o versionamento de arquivos sensíveis ou temporários.

Principais itens ignorados:

```text
.terraform/
*.tfstate
*.tfstate.*
terraform.tfvars
.vscode/
*.swp
.DS_Store
```

---

# Remoção da infraestrutura

Após finalizar todas as validações, os recursos podem ser removidos utilizando o Terraform.

Primeiro, verificar o workspace atual:

```bash
terraform workspace show
```

Selecionar o ambiente desejado:

```bash
terraform workspace select dev
```

Executar:

```bash
terraform destroy
```

Confirmar a destruição quando solicitado.

Para remover o ambiente PROD:

```bash
terraform workspace select prod
terraform destroy
```

O procedimento deve ser repetido para todos os ambientes utilizados.

> O bucket criado pelo bootstrap possui ciclo de vida independente da infraestrutura principal e deve ser tratado separadamente conforme a configuração do projeto.

---

---

# Evidências de destruição

Após a conclusão de todas as validações, os recursos provisionados pelo Terraform foram removidos utilizando:

```bash
terraform destroy
```

A remoção da infraestrutura principal foi validada diretamente na AWS.

A instância EC2 `web-dev` foi identificada como `terminated` e o Security Group utilizado pela aplicação não estava mais presente.

Também foi executado um novo:

```bash
terraform plan
```

após a destruição. O Terraform identificou que os recursos não estavam mais presentes na infraestrutura e apresentou:

```text
Plan: 8 to add, 0 to change, 0 to destroy.
```

Esse resultado demonstra que os recursos poderiam ser recriados a partir da configuração Terraform, caso um novo `terraform apply` fosse executado.

## Destruição do Bootstrap

Após a destruição da infraestrutura principal, o Bootstrap também foi removido.

O bucket S3 utilizado para armazenamento remoto do Terraform State continha os states dos workspaces `dev` e `prod`:

```text
env:/dev/projeto-final-iac/terraform.tfstate
env:/prod/projeto-final-iac/terraform.tfstate
```

Como o bucket não estava vazio, os objetos foram removidos antes da exclusão do bucket:

```bash
aws s3 rm s3://jessica-iac-projeto-final-iac --recursive
```

Após o esvaziamento do bucket, o recurso foi destruído pelo Terraform:

```bash
terraform destroy
```

Dessa forma, ao final do projeto, tanto a infraestrutura principal quanto o recurso utilizado pelo Bootstrap foram removidos da AWS.

As evidências dessa etapa estão registradas em:

- `terraform_09_destroy.png` - execução do `terraform destroy` da infraestrutura principal;
- `terraform_10_resources_destroyed.png` - validação da EC2 como `terminated` e ausência do Security Group;
- `terraform_11_plan_after_destroy.png` - `terraform plan` após a destruição da infraestrutura;
- `terraform_12_bootstrap_state.png` - recurso gerenciado pelo Terraform no Bootstrap;
- `terraform_13_bootstrap_bucket.png` - identificação do bucket S3 utilizado pelo Terraform State;
- `terraform_14_bootstrap_destroy.png` - execução do `terraform destroy` do Bootstrap;
- `terraform_15_bootstrap_destroyed.png` - validação da remoção do bucket S3.

> **Resultado final:** todos os recursos AWS criados durante a execução do laboratório foram removidos ao término do projeto.
---

# Fluxo completo de execução

A reprodução completa do projeto segue a sequência:

```text
1. Configurar credenciais AWS
             |
             v
2. Validar AWS CLI
             |
             v
3. Executar Bootstrap
             |
             v
4. Inicializar Terraform
             |
             v
5. Criar Workspace
             |
             v
6. terraform plan
             |
             v
7. terraform apply
             |
             v
8. Obter public_ip/public_dns
             |
             v
9. Entrar no diretório ansible/
             |
             v
10. Validar inventário dinâmico
             |
             v
11. ansible all -m ping
             |
             v
12. Executar playbook
             |
             v
13. Validar idempotência
             |
             v
14. Validar container
             |
             v
15. Validar aplicação internamente
             |
             v
16. Validar aplicação externamente
             |
             v
17. Validar aplicação no navegador
             |
             v
18. Configurar Ansible Vault
             |
             v
19. Executar playbook com Vault
             |
             v
20. Validar idempotência novamente
             |
             v
21. Documentar evidências
             |
             v
22. terraform destroy
```

---

# Conclusão

O projeto demonstrou a utilização conjunta de Terraform e Ansible para implementação de uma infraestrutura automatizada na AWS.

O Terraform foi utilizado para provisionar e gerenciar a infraestrutura, enquanto o Ansible realizou a configuração da instância EC2 e a implantação da aplicação em container Docker.

Também foram demonstrados:

- uso de módulos Terraform;
- utilização de Workspaces;
- backend remoto;
- consulta dinâmica da AMI;
- gerenciamento de Key Pair;
- inventário dinâmico AWS no Ansible;
- instalação e configuração do Docker;
- execução de container;
- mapeamento de portas;
- validação automatizada;
- idempotência;
- Ansible Vault;
- troubleshooting de infraestrutura;
- sincronização do Terraform State;
- validação da aplicação via HTTP;
- organização de evidências.

O resultado final é uma infraestrutura reproduzível, automatizada e documentada, utilizando práticas de Infraestrutura como Código.

---

# Autora

**Jessica Camarço**

**Curso:** Pós-graduação em DevOps

**Disciplina:** Infraestrutura como Código (IaC)

**Projeto:** Projeto Final - Infraestrutura como Código com Terraform e Ansible

---

# Repositório

O código-fonte, arquivos de configuração, módulos Terraform, playbooks Ansible e evidências do projeto estão disponíveis no GitHub:

**GitHub:** https://github.com/jessicacamarco/projeto-final-iac