#!/bin/bash

rocketchat_directory="/tmp"
rocketchat_versions=("3.7.0" "4.0.0" "4.5.0" "4.8.7")

function check_package() {
    dpkg -s "$1" >/dev/null 2>&1
}

function check_command() {
    command -v "$1" >/dev/null 2>&1
}

function install_package() {
    if check_package "$1"; then
        echo "$1 já está instalado."
    else
        echo "Instalando $1..."
        sudo apt-get -y install "$1"
        echo "Instalação de $1 concluída."
    fi
}

if ! check_command sudo; then
    echo "Erro: 'sudo' não encontrado. Este script deve ser executado com privilégios de sudo."
    exit 1
fi

if [ ! -d "$rocketchat_directory" ]; then
    echo "Diretório $rocketchat_directory não encontrado. Criando diretório..."
    mkdir -p "$rocketchat_directory"
    if [ $? -ne 0 ]; then
        echo "Erro ao criar o diretório: $rocketchat_directory"
        exit 1
    fi
    echo "Diretório $rocketchat_directory criado"
fi

echo "Atualizando os pacotes do sistema..."
sudo apt-get -y update
echo "Atualização concluída."

install_package "gnupg"
install_package "jq"

echo "Atualizando os pacotes do sistema novamente..."
sudo apt-get -y update
echo "Atualização concluída."

for version in ${rocketchat_versions[@]}; do
    echo "Atualizando para RocketChat versão $version..."

    systemctl stop rocketchat
    if [ $? -ne 0 ]; then
        echo "Erro ao parar o serviço RocketChat"
        exit 1
    fi

    echo "Verificando se o Rocket.Chat já está instalado..."
    if [ -d "/opt/Rocket.Chat" ]; then
        echo "Rocket.Chat encontrado."
        echo "Removendo conteúdo de /opt/Rocket.Chat/*"
        rm -Rf "/opt/Rocket.Chat/"*
        if [ $? -ne 0 ]; then
            echo "Erro ao remover conteúdo /opt/Rocket.Chat/*"
            exit 1
        fi
    fi

    echo "Baixando o Rocket.Chat..."

    cd "$rocketchat_directory"

    curl -L "https://releases.rocket.chat/$version/download" -o rocket.chat.tgz
    if [ $? -ne 0 ]; then
        echo "Erro ao baixar RocketChat versão $version"
        exit 1
    fi

    tar zxvf rocket.chat.tgz
    if [ $? -ne 0 ]; then
        echo "Erro ao extrair RocketChat versão $version"
        exit 1
    fi
    
    sudo chown -R $USER:$USER "$rocketchat_directory/bundle"
    
    cd "bundle/"
    if [ $? -ne 0 ]; then
        echo "Erro ao acessar o diretório do servidor RocketChat"
        exit 1
    fi

    sudo chown -R $USER:$USER 

    node_version=$(jq -r '.nodeVersion' star.json)
    if [ $? -ne 0 ]; then
        echo "Erro ao extrair a versão do Node.js do arquivo package.json"
        exit 1
    fi

    cd "programs/server"
    if [ $? -ne 0 ]; then
        echo "Erro ao acessar o diretório do servidor RocketChat"
        exit 1
    fi

    echo "Verificando a versão do Node.js..."
    if ! command -v nvm >/dev/null; then
        echo "nvm não encontrado. Instalando nvm..."
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    fi

    if command -v nvm >/dev/null; then
        echo "nvm encontrado. Usando a versão do Node.js: $node_version"
        nvm install "$node_version"
        if [ $? -ne 0 ]; then
            echo "Erro ao instalar Node.js versão $node_version"
            exit 1
        fi


        nvm use "$node_version"
        if [ $? -ne 0 ]; then
            echo "Erro ao usar Node.js versão $node_version"
            exit 1
        fi
    else
        echo "nvm não encontrado. Certifique-se de que o nvm esteja instalado corretamente."
        exit 1
    fi  

    sudo env PATH="$PATH" $(command -v npm) install --production
    if [ $? -ne 0 ]; then
        echo "Erro ao instalar dependências"
        exit 1
    fi
    
    if [ -d "$rocketchat_directory/bundle/" ]; then
            echo "Movendo arquivos para o diretório RocketChat..."
            mv -f "$rocketchat_directory/bundle/"* "/opt/Rocket.Chat/"
            if [ $? -ne 0 ]; then
                echo "Erro ao mover arquivos para o diretório RocketChat"
                exit 1
            fi
        else
            echo "Diretório $rocketchat_directory/bundle/ não encontrado. Verifique se a extração do Rocket.Chat foi bem-sucedida."
            exit 1
        fi

    chown -R rocketchat:rocketchat "/opt/Rocket.Chat/"
    if [ $? -ne 0 ]; then
        echo "Erro ao corrigir permissões"
        exit 1
    fi

    while true; do
        if systemctl is-active --quiet rocketchat; then
            echo "Serviço Rocket.Chat está em execução."
            break
        else
            echo "Serviço Rocket.Chat não está em execução. Tentando iniciar..."
            systemctl start rocketchat
            sleep 60
        fi
    done

    curl -f http://localhost:3000
    if [ $? -ne 0 ]; then
        echo "Rocket.Chat não está respondendo"
        exit 1
    fi

done

echo "Atualização concluída com sucesso e serviços estão rodando corretamente!" 
