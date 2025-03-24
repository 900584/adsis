#!/bin/bash
# 900584, Puertolas Merenciano, David

bin_dir=$(find $HOME -maxdepth 1 -type d -name "bin???" -printf "%T@ %p\n" 2>/dev/null | sort -nr | head -n1 | cut -d' ' -f2)

if [ -z "$bin_dir" ]; then
    bin_dir=$(mktemp -d "$HOME/binXXX")
    echo "Se ha creado el directorio $bin_dir"
    
fi

echo "Directorio destino de copia: $bin_dir"

count=0
for file in *; do
    if [ -x "$file" ] && [ -f "$file" ]; then
        if [ ! -e "$bin_dir/$(basename "$file")" ]; then
            cp "$file" "$bin_dir"
            echo "./$file ha sido copiado a $bin_dir"
            ((count++))
        fi
    fi
done

if [ $count -eq 0 ]; then
    echo "No se ha copiado ningun archivo"
else
    echo "Se han copiado $count archivos"
fi
