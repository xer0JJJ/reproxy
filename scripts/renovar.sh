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
# Renovação do Certificado
# ---------------------------------------------------------------------

renew_certificate() {

    echo "Renovando certificados..."

    docker compose run --rm certbot renew

    echo "Certificados........... OK"

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

    local CRON_JOB="0 22 */2 * * ${ROOT_DIR}/scripts/renovar.sh"

    (
        crontab -l 2>/dev/null | grep -Fv "${ROOT_DIR}/scripts/renovar.sh" || true
        echo "${CRON_JOB}"
    ) | crontab -

    echo "Cron................... Instalado"

}

# ---------------------------------------------------------------------
# Remove Cron
# ---------------------------------------------------------------------

remove_cron() {

    (
        crontab -l 2>/dev/null | grep -Fv "${ROOT_DIR}/scripts/renovar.sh" || true
    ) | crontab -

    echo "Cron................... Removido"

}

# ---------------------------------------------------------------------
# Status Cron
# ---------------------------------------------------------------------

status_cron() {

    if crontab -l 2>/dev/null | grep -Fq "${ROOT_DIR}/scripts/renovar.sh"; then

        echo "Cron................... Instalado"

    else

        echo "Cron................... Não instalado"

    fi

}

# ---------------------------------------------------------------------
# Resumo
# ---------------------------------------------------------------------

summary() {

    echo
    echo "=========================================================="
    echo "Operação concluída com sucesso."
    echo "=========================================================="
    echo

}

main() {

    case "${1:-}" in

        "")

            banner

            check_env
            load_env
            validate_env

            renew_certificate

            reload_nginx

            summary

        ;;

        --install-cron)

            banner

            install_cron

        ;;

        --remove-cron)

            banner

            remove_cron

        ;;

        --status)

            banner

            status_cron

        ;;

        *)

            echo
            echo "ERRO"
            echo
            echo "Parâmetro inválido: ${1}"
            echo
            echo "Parâmetros disponíveis:"
            echo "  --install-cron"
            echo "  --remove-cron"
            echo "  --status"
            echo

            exit 1

        ;;

    esac

}

main "$@"





