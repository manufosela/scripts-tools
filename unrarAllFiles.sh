#!/bin/bash

# Verificar si se pasó un directorio como parámetro
if [ -z "$1" ]; then
  echo "Por favor, especifica un directorio."
  exit 1
fi

# Directorio donde buscar los archivos .rar (recibido como argumento)
DIRECTORY="$1"

# Verificar si el directorio existe
if [ ! -d "$DIRECTORY" ]; then
  echo "El directorio especificado no existe: $DIRECTORY"
  exit 1
fi

# Buscar archivos .rar que contengan "part1" en el nombre
for file in "$DIRECTORY"/*part1.rar; do
  # Verificar si el archivo existe
  if [ ! -f "$file" ]; then
    echo "No se encontraron archivos .rar en: $DIRECTORY"
    break
  fi

  # Obtener la ruta del directorio de destino (mismo nombre del archivo sin extensión)
  BASENAME=$(basename "$file" .part1.rar)
  TARGET_DIR="$DIRECTORY/$BASENAME"

  # Verificar si el directorio ya existe y contiene archivos
  if [ -d "$TARGET_DIR" ] && [ "$(ls -A "$TARGET_DIR")" ]; then
    echo "El archivo ya está descomprimido: $file"
    continue
  fi

  # Crear el directorio de destino si no existe
  mkdir -p "$TARGET_DIR"

  # Mostrar mensaje indicando el archivo que se comenzará a descomprimir
  echo "Comenzando a descomprimir: $file"

  # Descomprimir el archivo .rar en su propio directorio y usar -o- para no sobrescribir archivos existentes
  unrar x -o- "$file" "$TARGET_DIR"

  # Verificar si la descomposición fue exitosa
  if [ $? -eq 0 ]; then
    echo "Descomprimido con éxito: $file"
  else
    echo "Error al descomprimir: $file"
  fi
done

