#!/bin/bash
# 900584, Puertolas Merenciano, David

if [[ $# -ne 3 ]]; then
    echo "Numero incorrecto de parametros"
    exit 1
fi

modo=$1
user_file=$2
machine_file=$3

if [[ "$modo" != "-a" && "$modo" != "-s" ]]; then
    echo "Opcion invalida"
    exit 1
fi

if [[ "$modo" == "-s" ]]; then
    remote_backup_cmd="mkdir -p /extra/backup"
fi

while IFS= read -r ip; do
    if ! ssh -i ~/.ssh/id_ed25519 -o ConnectTimeout=3 -o StrictHostKeyChecking=no "$ip" "echo" &>/dev/null; then
        echo "$ip no es accesible"
        continue
    fi

    # Subir el archivo de usuarios a la máquina remota
    scp -i ~/.ssh/id_ed25519 -o StrictHostKeyChecking=no "$user_file" "$ip:/tmp/users.txt" &>/dev/null

    # Ejecutar los comandos en la máquina remota
    ssh -i ~/.ssh/id_ed25519 -o StrictHostKeyChecking=no "$ip" bash -s <<EOF
if [[ "$modo" == "-s" ]]; then
    $remote_backup_cmd
fi

while IFS=, read -r usuario password nombre_completo; do
    usuario=\$(echo "\$usuario" | xargs)
    password=\$(echo "\$password" | xargs)
    nombre_completo=\$(echo "\$nombre_completo" | xargs)

    if [[ "$modo" == "-a" ]]; then
        if [[ -z "\$usuario" || -z "\$password" || -z "\$nombre_completo" ]]; then
            echo "Campo invalido"
            exit 1
        fi

        if id "\$usuario" &>/dev/null; then
            echo "El usuario \$usuario ya existe"
        else
            sudo useradd -K UID_MIN=1815 -U -c "\$nombre_completo" -m -k /etc/skel "\$usuario"
            echo "\$usuario:\$password" | sudo chpasswd
            sudo usermod -e \$(date -d "+30 days" +%Y-%m-%d) "\$usuario"
            echo "\$nombre_completo ha sido creado"
        fi
    else
        if [[ -z "\$usuario" ]]; then
            echo "Campo invalido"
            exit 1
        fi

        if id "\$usuario" &>/dev/null; then
            home_dir=\$(eval echo ~\$usuario)
            if [ -d "\$home_dir" ]; then
                sudo tar -cf "/extra/backup/\$usuario.tar" "\$home_dir" &>/dev/null
                if [[ \$? -eq 0 ]]; then
                    sudo userdel -r "\$usuario"
                fi
            else
                sudo userdel "\$usuario"
            fi
        fi
    fi
done < /tmp/users.txt
EOF

done < "$machine_file"

exit 0
