#!/bin/bash
# 900584, Puertolas Merenciano, David

read -p "Introduzca el nombre de un directorio: " dir
if [ ! -d "$dir" ]; then
    echo "$dir no es un directorio"
    exit 1
fi
num_files=$(find "$dir" -maxdepth 1 -type f | wc -l)
num_dirs=$(find "$dir" -maxdepth 1 -type d | wc -l)
echo "El numero de ficheros y directorios en $dir es de $num_files y $((num_dirs - 1)), respectivamente"