#!/usr/bin/env bash
set -e

# ==============================================================================
# Script de Ejecución Rápida - Microservicio Onion Architecture en Aura Lang
# ==============================================================================

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
cd "$DIR"

echo "================================================================================"
echo "  🧅 INICIALIZANDO MICROSERVICIO ONION EN AURA (GOLANG IDIOMATIC STYLE)"
echo "================================================================================"

# 1. Ejecución de Pruebas Unitarias de Dominio
echo ""
echo ">> [1/3] Ejecutando Pruebas Unitarias de Capa de Dominio..."
aurac run tests/domain_test.aura

# 2. Ejecución de Pruebas Unitarias de Casos de Uso
echo ""
echo ">> [2/3] Ejecutando Pruebas Unitarias de Casos de Uso (Capa de Aplicación)..."
aurac run tests/usecase_test.aura

# 3. Ejecución de Pruebas de Integración
echo ""
echo ">> [3/4] Ejecutando Pruebas de Integración End-to-End..."
aurac run tests/integration_test.aura

# 4. Lanzamiento del Servidor
echo ""
echo ">> [4/4] Lanzando Servidor HTTP REST (Composition Root)..."
aurac run cmd/server/main.aura
