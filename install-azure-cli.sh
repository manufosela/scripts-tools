#!/bin/bash

# Script para instalar Azure CLI en sistemas basados en Debian/Ubuntu

# Salir en caso de error
set -e

# Actualizar el sistema
echo "Actualizando el sistema..."
sudo apt update && sudo apt upgrade -y

# Instalar requisitos previos
echo "Instalando requisitos previos..."
sudo apt install -y ca-certificates curl apt-transport-https

# Agregar clave GPG de Microsoft
echo "Agregando clave GPG de Microsoft..."
curl -sL https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --dearmor -o /usr/share/keyrings/microsoft-archive-keyring.gpg

# Agregar repositorio de Azure CLI
echo "Agregando repositorio de Azure CLI..."
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/microsoft-archive-keyring.gpg] https://packages.microsoft.com/repos/azure-cli/ $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/azure-cli.list

# Actualizar repositorios
echo "Actualizando repositorios..."
sudo apt update

# Instalar Azure CLI
echo "Instalando Azure CLI..."
sudo apt install -y azure-cli

# Verificar instalación
echo "Verificando la instalación de Azure CLI..."
az version

# Mensaje de éxito
echo "Azure CLI se ha instalado correctamente."

echo "Inicia sesión usando 'az login'."

