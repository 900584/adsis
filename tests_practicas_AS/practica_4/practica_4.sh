#!/bin/bash
# 900584, Puertolas Merenciano, David

if [[ $EUID -ne 0 ]]; then
    echo "Este script necesita privilegios de administracion" >&2
    exit 1
fi

if [[ $# -ne 3 ]]; then
    echo "Uso: $0 [-a|-s] <usuarios.txt> <maquinas.txt>"
    exit 1
fi

modo="$1"
usuarios_file="$2"
maquinas_file="$3"

if [[ "$modo" != "-a" && "$modo" != "-s" ]]; then
    echo "Opcion invalida" >&2
    exit 1
fi

while read -r ip; do
    echo "Conectando a $ip..."

    ssh -i ~/.ssh/id_ed25519 -o ConnectTimeout=5 -o StrictHostKeyChecking=no as@"$ip" "bash -s" <<EOF
#!/bin/bash

if [[ "$modo" == "-s" ]]; then
    mkdir -p /extra/backup
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
            useradd -K UID_MIN=1815 -U -c "\$nombre_completo" -m -k /etc/skel "\$usuario"
            echo "\$usuario:\$password" | chpasswd
            usermod -e \$(date -d "+30 days" +%Y-%m-%d) "\$usuario"
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
                tar -cf "/extra/backup/\$usuario.tar" "\$home_dir" &>/dev/null
                if [[ \$? -eq 0 ]]; then
                    userdel -r "\$usuario"
                fi
            else
                userdel "\$usuario"
            fi
        fi
    fi
done < <(cat <<USERS
$(cat "$usuarios_file")
USERS
)

EOF

done < "$maquinas_file"

exit 0
