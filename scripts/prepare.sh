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

COMPOSE_TEMPLATE="${ROOT_DIR}/templates/docker-compose.default.yml"
COMPOSE_FILE="${ROOT_DIR}/docker-compose.yml"

APP_TEMPLATE="${ROOT_DIR}/templates/app.conf.default"
APP_CONF="${ROOT_DIR}/nginx/conf.d/app.conf"

REQUIRED_FILES=(

    "${COMPOSE_TEMPLATE}"
    "${APP_TEMPLATE}"

    "${ROOT_DIR}/nginx/nginx.conf"

    "${ROOT_DIR}/nginx/snippets/headers.conf"
    "${ROOT_DIR}/nginx/snippets/gzip.conf"
    "${ROOT_DIR}/nginx/snippets/logging.conf"

)

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
# Verificação da Estrutura
# ---------------------------------------------------------------------

check_project() {

    echo "Verificando estrutura do projeto..."

    for file in "${REQUIRED_FILES[@]}"; do

        if [[ ! -f "$file" ]]; then

            echo
            echo "ERRO"
            echo
            echo "Arquivo obrigatório não encontrado:"
            echo "  $file"
            echo

            exit 1

        fi

    done

    echo "Estrutura............... OK"

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
        BACKEND_HOST
        BACKEND_PORT
        DOMAIN
        EMAIL
        TZ
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

    if [[ -n "${CUSTOM_PORT:-}" ]]; then

        if [[ -n "${HTTP_PORT:-}" ]] || [[ -n "${HTTPS_PORT:-}" ]]; then

            echo
            echo "ERRO"
            echo
            echo "CUSTOM_PORT não pode ser utilizado"
            echo "juntamente com HTTP_PORT ou HTTPS_PORT."
            echo

            exit 1

        fi

    fi

    echo "Variáveis............... OK"

}

# ---------------------------------------------------------------------
# Geração das Portas
# ---------------------------------------------------------------------

generate_ports() {

    if [[ -n "${CUSTOM_PORT:-}" ]]; then

        echo "      - \"${CUSTOM_PORT}:80\""

        return

    fi

    [[ -n "${HTTP_PORT:-}" ]] && \
        echo "      - \"${HTTP_PORT}:80\""

    [[ -n "${HTTPS_PORT:-}" ]] && \
        echo "      - \"${HTTPS_PORT}:443\""

}

# ---------------------------------------------------------------------
# Geração do Docker Compose
# ---------------------------------------------------------------------

generate_compose() {

    echo "Gerando docker-compose.yml..."

    local SKIP_PORTS=false

    : > "$COMPOSE_FILE"

    while IFS= read -r line || [[ -n "$line" ]]; do

        if $SKIP_PORTS; then

            if [[ "$line" =~ ^[[:space:]]*-[[:space:]] ]]; then
                continue
            fi

            SKIP_PORTS=false

        fi

        if [[ "$line" =~ ^[[:space:]]*ports:[[:space:]]*$ ]]; then

            echo "$line" >> "$COMPOSE_FILE"

            generate_ports >> "$COMPOSE_FILE"

            SKIP_PORTS=true

            continue

        fi

        echo "$line" >> "$COMPOSE_FILE"

    done < "$COMPOSE_TEMPLATE"

    echo "Docker Compose.......... OK"

}

# ---------------------------------------------------------------------
# Geração do App Conf
# ---------------------------------------------------------------------

generate_app_conf() {

    echo "Gerando app.conf..."

    : > "$APP_CONF"

    cat >> "$APP_CONF" << 'EOF'
# =====================================================================
# ESTE ARQUIVO FOI GERADO AUTOMATICAMENTE PELO prepare.sh
#
# Este arquivo será sobrescrito sempre que o prepare.sh for executado.
#
# Para alterações permanentes, edite:
# templates/app.conf.default
# =====================================================================

EOF

    while IFS= read -r line || [[ -n "$line" ]]; do
 
        echo "${line//exemplo.com.br/${DOMAIN}}" >> "$APP_CONF"

    done < "$APP_TEMPLATE"

    echo "App Conf................ OK"

}

# ---------------------------------------------------------------------
# Corrige Permissões
# ---------------------------------------------------------------------

fix_permissions() {

    echo "Corrigindo permissões..."

    find "$ROOT_DIR" -type d -exec chmod 755 {} \;
    find "$ROOT_DIR" -type f -name "*.sh" -exec chmod 755 {} \;

    [[ -f "$COMPOSE_FILE" ]] && chmod 644 "$COMPOSE_FILE"
    [[ -f "$APP_CONF" ]] && chmod 644 "$APP_CONF"

    echo "Permissões............. OK"

}

# ---------------------------------------------------------------------
# Resumo
# ---------------------------------------------------------------------

summary() {

    echo
    echo "=========================================================="
    echo "Ambiente preparado com sucesso."
    echo "=========================================================="
    echo

}

main() {

    banner

    check_project
    check_env
    load_env
    validate_env

    generate_compose
    generate_app_conf

    fix_permissions

    summary

}

main "$@"
