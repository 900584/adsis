#!/bin/bash
# 900584, Puertolas Merenciano, David

read -p "Introduzca el nombre del fichero: " filename
if [ ! -e "$filename" ]; then
    echo "$filename no existe"
else
    perms=$(ls -l "$filename" | cut -c 2-4)
    echo "Los permisos del archivo $filename son: $perms"
fi
