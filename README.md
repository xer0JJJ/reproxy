# =====================================================================

# Reverse Proxy Template v1.0 by xer0

# =====================================================================

# ---------------------------------------------------------------------

# SOBRE

# ---------------------------------------------------------------------

Reverse Proxy Template é uma base padronizada para publicação de
aplicações utilizando Docker, Nginx e Let's Encrypt.

O projeto foi desenvolvido para administradores de infraestrutura que
desejam padronizar seus ambientes, automatizar tarefas repetitivas e
manter total controle sobre suas configurações.

O objetivo não é substituir o conhecimento do administrador, mas
fornecer uma estrutura reutilizável, organizada e portátil para
implantação de proxies reversos.

# ---------------------------------------------------------------------

# FILOSOFIA

# ---------------------------------------------------------------------

* Simplicidade acima de complexidade.
* Automação sem esconder o funcionamento.
* Padronização sem limitar o administrador.
* Nenhum script é obrigatório.
* Toda configuração pode ser realizada manualmente.
* O projeto deve ser totalmente portátil.
* Cada arquivo possui apenas uma responsabilidade.

# ---------------------------------------------------------------------

# ESTRUTURA DO PROJETO

# ---------------------------------------------------------------------

reproxy/
│
├── .env.example
├── README.md
├── VERSION
│
├── templates/
│   └── docker-compose.default.yml
│   └── app.conf.default

│
├── nginx/
│   ├── nginx.conf
│   ├── conf.d/
│   │   └── app.conf
│   └── snippets/
│       ├── headers.conf
│       ├── gzip.conf
│       └── logging.conf
│
├── certbot/
│   ├── conf/
│   └── www/
│
├── logs/
│   ├── nginx/
│   └── certbot/
│
├── backups/
│
└── scripts/
├── prepare.sh
├── emitir.sh
├── renovar.sh
├── backup.sh
├── restore.sh
├── healthcheck.sh
└── permissions.sh

# ---------------------------------------------------------------------

# FLUXO RECOMENDADO

# ---------------------------------------------------------------------

1. Copie o arquivo de configuração.

   cp .env.example .env

2. Configure o ambiente através do arquivo .env.

3. Configure a aplicação em:

   nginx/conf.d/app.conf

4. Execute o script de preparação.

   ./scripts/prepare.sh

5. Inicie os containers.

   docker compose up -d

6. Emita o certificado.

   ./scripts/emitir.sh

# ---------------------------------------------------------------------

# CONFIGURAÇÃO DA APLICAÇÃO

# ---------------------------------------------------------------------
Toda a configuração da aplicação deverá ser realizada anteriormente no arquivo:

templates/app.conf.default

caso deseje editar depois, pode editar direto no nginx/conf.d/app.conf antes de subir o docker.

Este arquivo representa o modelo utilizado pelo prepare.sh para gerar:

nginx/conf.d/app.conf

Durante a preparação do ambiente, o prepare.sh gera automaticamente
o arquivo final da aplicação, preservando a configuração padrão do
template.

Toda a configuração referente à publicação da aplicação deverá ser
realizada neste arquivo, incluindo:

* Domínio (server_name)
* Proxy Reverso (proxy_pass)
* Localizações (location)
* SSL
* Timeouts
* Uploads
* WebSocket
* Regras específicas da aplicação

Como cada aplicação possui necessidades diferentes, o template
permanece sob total controle do administrador.

# ---------------------------------------------------------------------

# FLUXO MANUAL

# ---------------------------------------------------------------------

Arquivos normalmente editados:

* .env
* templates/docker-compose.default.yml
* nginx/conf.d/app.conf

docker-compose.yml

Gerado automaticamente pelo prepare.sh.

nginx/conf.d/app.conf

Gerado automaticamente pelo prepare.sh.

Após a configuração:

docker compose up -d

Nenhum script é obrigatório para o funcionamento do projeto.

# ---------------------------------------------------------------------

# ARQUIVOS PRINCIPAIS

# ---------------------------------------------------------------------

Os seguintes arquivos representam a fonte de verdade do projeto.

.env

```
Configuração do ambiente.
```

templates/docker-compose.default.yml

```
Modelo padrão utilizado para geração do Docker Compose.
```

nginx/conf.d/app.conf

```
Configuração específica da aplicação.
```

# ---------------------------------------------------------------------

# ARQUIVOS GERADOS

# ---------------------------------------------------------------------

docker-compose.yml

```
Gerado automaticamente pelo prepare.sh.
```

Sempre que o prepare.sh for executado, este arquivo será recriado
utilizando como base:

* .env
* templates/docker-compose.default.yml

Alterações permanentes devem ser realizadas nesses arquivos.

# ---------------------------------------------------------------------

# SCRIPTS

# ---------------------------------------------------------------------

prepare.sh

```
Responsável por preparar o ambiente.

Funções:

- Validar o arquivo .env.
- Validar a estrutura do projeto.
- Criar diretórios necessários.
- Gerar o docker-compose.yml.
```

emitir.sh

```
Primeira emissão do certificado Let's Encrypt.
```

renovar.sh

```
Renovação automática dos certificados.
```

backup.sh

```
Backup da configuração do projeto.
```

restore.sh

```
Restauração de um backup.
```

healthcheck.sh

```
Verificação da integridade da stack.
```

permissions.sh

```
Padronização das permissões dos arquivos.
```

# ---------------------------------------------------------------------

# VARIÁVEIS DE AMBIENTE

# ---------------------------------------------------------------------

Toda a configuração do ambiente é realizada através do arquivo .env.

As principais configurações incluem:

* Backend
* Let's Encrypt
* Timezone
* Portas publicadas

# ---------------------------------------------------------------------

# PORTABILIDADE

# ---------------------------------------------------------------------

Todo o projeto foi desenvolvido para permanecer autocontido.

Toda configuração permanece dentro da estrutura do projeto,
permitindo backup, restauração e migração simplificados.

# ---------------------------------------------------------------------

# PÚBLICO-ALVO

# ---------------------------------------------------------------------

Este projeto destina-se a profissionais que já possuem conhecimentos
básicos em:

* Docker
* Docker Compose
* Linux
* Nginx
* Redes

Não é objetivo deste projeto ensinar esses conceitos.

# ---------------------------------------------------------------------

# VERSIONAMENTO

# ---------------------------------------------------------------------

Versão Atual

```
1.0.0
```

# ---------------------------------------------------------------------

# CHANGELOG

# ---------------------------------------------------------------------

v1.0.0

* Estrutura inicial do projeto.
* Docker Compose baseado em template.
* Nginx modular.
* Scripts independentes.
* Administração manual com automação opcional.
* Arquitetura totalmente portátil.

# ---------------------------------------------------------------------
# RENOVAÇÃO AUTOMÁTICA
# ---------------------------------------------------------------------

O comando abaixo instala automaticamente uma tarefa no cron do sistema
para executar a renovação dos certificados a cada dois dias, às 22:00.

./scripts/renovar.sh --install-cron

Caso deseje utilizar outro horário ou periodicidade, edite
manualmente a entrada criada no cron após a instalação.

# =====================================================================

# Reverse Proxy Template v1.0 by xer0

# =====================================================================

