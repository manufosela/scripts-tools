#!/bin/bash

# Verificar si se pasó un directorio como parámetro
if [ -z "$1" ]; then
  echo "Por favor, especifica un directorio."
  exit 1
fi

# Directorio donde buscar los archivos .rar con part1 (recibido como argumento)
DIRECTORY="$1"

# Verificar si el directorio existe
if [ ! -d "$DIRECTORY" ]; then
  echo "El directorio especificado no existe: $DIRECTORY"
  exit 1
fi

# Buscar archivos .rar que contengan "part1" en el nombre
find "$DIRECTORY" -name "*part1*.rar" | while read -r file; do
  # Obtener el directorio donde está el archivo .rar
  file_dir=$(dirname "$file")
  
  # Mostrar mensaje indicando el archivo que se comenzará a descomprimir
  echo "Comenzando a descomprimir: $file"

  # Descomprimir el archivo .rar en su propio directorio y mostrar la salida de unrar
  unrar x "$file" "$file_dir"

  # Verificar si la descompresión fue exitosa
  if [ $? -eq 0 ]; then
    echo "Descomprimido con éxito: $file"
  else
    echo "Error al descomprimir: $file"
  fi
done

