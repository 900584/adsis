#!/bin/bash
# 900584, Puertolas Merenciano, David

if [ $# -ne 1 ]; then
    echo "Sintaxis: practica2_3.sh <nombre_archivo>"
    exit 1
fi
file="$1"
if [ ! -f "$file" ]; then
    echo "$file no existe o no es un fichero"
    exit 1
fi
chmod ug+x "$file"
stat -c "%A" "$file"