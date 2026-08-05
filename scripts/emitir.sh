#!/usr/bin/env bash

# =====================================================================
# Reverse Proxy Template v1.0 by xer0
# =====================================================================

set -euo pipefail
IFS=$'\n\t'

# ---------------------------------------------------------------------
# Informações do Projeto
# ---------------------------------------------------------------------

PROJECT_NAME="Reverse Proxy Template"
PROJECT_VERSION="v1.0"
PROJECT_AUTHOR="xer0"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

ENV_FILE="${ROOT_DIR}/.env"

INSTALL_CRON=false

# ---------------------------------------------------------------------
# Banner
# ---------------------------------------------------------------------

banner() {

    echo "=========================================================="
    echo "${PROJECT_NAME} ${PROJECT_VERSION} by ${PROJECT_AUTHOR}"
    echo "=========================================================="
    echo

}

# ---------------------------------------------------------------------
# Verificação do .env
# ---------------------------------------------------------------------

check_env() {

    if [[ ! -f "$ENV_FILE" ]]; then

        echo
        echo "ERRO"
        echo
        echo "Arquivo .env não encontrado."
        echo "Copie .env.example para .env."
        echo

        exit 1

    fi

    echo ".env.................... OK"

}

# ---------------------------------------------------------------------
# Carrega Variáveis
# ---------------------------------------------------------------------

load_env() {

    # shellcheck disable=SC1090
    source "$ENV_FILE"

}

# ---------------------------------------------------------------------
# Validação
# ---------------------------------------------------------------------

validate_env() {

    local REQUIRED_VARS=(
        DOMAIN
        EMAIL
    )

    for var in "${REQUIRED_VARS[@]}"; do

        if [[ -z "${!var:-}" ]]; then

            echo
            echo "ERRO"
            echo
            echo "Variável obrigatória:"
            echo "  $var"
            echo

            exit 1

        fi

    done

    echo "Variáveis............... OK"

}

# ---------------------------------------------------------------------
# Emite Certificado
# ---------------------------------------------------------------------

issue_certificate() {

    echo "Iniciando Nginx..."

    docker compose up -d nginx >/dev/null
    sleep 2
    
    echo "Nginx.................. OK"
    echo
    echo "Emitindo certificado..."

    docker compose run --rm certbot \
        certonly \
        --webroot \
        --webroot-path /var/www/certbot \
        --email "$EMAIL" \
        --agree-tos \
        --no-eff-email \
	--non-interactive \
        -d "$DOMAIN"

    echo "Certificado............ OK"

}

# ---------------------------------------------------------------------
# Habilita HTTPS
# ---------------------------------------------------------------------

enable_https_server() {

    sed -i '/AUTO_ENABLE_SSL/{
        n
        :a
        s/^#//
        n
        ba
    }' "${ROOT_DIR}/nginx/conf.d/app.conf"

    echo "HTTPS.................. OK"

}

# ---------------------------------------------------------------------
# Habilita Redirect HTTPS
# ---------------------------------------------------------------------

enable_https_redirect() {

    sed -i '/AUTO_REDIRECT_SSL/{n;s/^[[:space:]]*# *//;}' \
        "${ROOT_DIR}/nginx/conf.d/app.conf"

    echo "Redirect HTTPS........ OK"

}

# ---------------------------------------------------------------------
# Recarrega o Nginx
# ---------------------------------------------------------------------

reload_nginx() {

    echo "Recarregando Nginx..."

    docker compose exec -T nginx nginx -t >/dev/null

    docker compose exec -T nginx nginx -s reload >/dev/null

    echo "Nginx.................. OK"

}

# ---------------------------------------------------------------------
# Instala Cron
# ---------------------------------------------------------------------

install_cron() {

    "${ROOT_DIR}/scripts/renovar.sh" --install-cron

}

# ---------------------------------------------------------------------
# Resumo
# ---------------------------------------------------------------------

summary() {

    echo
    echo "=========================================================="
    echo "Certificado emitido com sucesso."
    echo "=========================================================="
    echo

}

main() {

    if [[ -n "${1:-}" ]] && [[ "${1}" != "--install-cron" ]]; then

        echo
        echo "ERRO"
        echo
        echo "Parâmetro inválido: ${1}"
        echo

        exit 1

    fi

    [[ "${1:-}" == "--install-cron" ]] && INSTALL_CRON=true

    banner

    check_env
    load_env
    validate_env

    issue_certificate

    enable_https_server

    enable_https_redirect

    reload_nginx

    if $INSTALL_CRON; then
        install_cron
    fi

    summary

}

main "$@"
