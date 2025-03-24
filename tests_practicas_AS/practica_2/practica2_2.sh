#!/bin/bash
# 900584, Puertolas Merenciano, David

for file in "$@"; do
    if [ -f "$file" ]; then
        more "$file"
    else
        echo "$file no es un fichero"
    fi
done