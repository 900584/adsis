#!/bin/bash
# 900584, Puertolas Merenciano, David

read -n 1 -p "Introduzca una tecla: " tecla
echo ""
if [[ "$tecla" =~ [a-zA-Z] ]]; then
    echo "$tecla es una letra"
elif [[ "$tecla" =~ [0-9] ]]; then
    echo "$tecla es un numero"
else
    echo "$tecla es un caracter especial"
fi
