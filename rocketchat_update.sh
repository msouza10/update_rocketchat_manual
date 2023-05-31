#!/bin/bash

# Lista de versões para atualizar
rocketchat_versions=("1.0.1" "1.0.2" "1.0.3" "1.1.0" "1.1.1")
node_versions=("12.14.0" "12.14.1" "12.14.2" "12.15.0" "12.15.1")

# Loop para atualizar versão por versão
for i in ${!rocketchat_versions[@]}
do
    echo "Atualizando para a versão ${rocketchat_versions[$i]}..."
    
    # Parando o serviço RocketChat
    systemctl stop rocketchat
    if [ $? -ne 0 ]; then
        echo "Erro ao parar o serviço RocketChat"
        exit 1
    fi

    # Atualizando NVM
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    nvm install ${node_versions[$i]}
    nvm use ${node_versions[$i]}
    if [ $? -ne 0 ]; then
        echo "Erro ao atualizar NVM e Node.js"
        exit 1
    fi

    # Baixando a nova versão
    curl -L https://releases.rocket.chat/${rocketchat_versions[$i]}/download -o /tmp/rocket.chat.tgz
    
    # Descompactando o arquivo baixado
    tar -xzf /tmp/rocket.chat.tgz -C /tmp
    if [ $? -ne 0 ]; then
        echo "Erro ao descompactar o arquivo baixado"
        exit 1
    fi

    # Copiando a atualização para o diretório do RocketChat
    cp -R /tmp/bundle/* /opt/Rocket.Chat
    if [ $? -ne 0 ]; then
        echo "Erro ao copiar a atualização para o diretório do RocketChat"
        exit 1
    fi

    # Mudando para o diretório do servidor RocketChat
    cd /opt/Rocket.Chat/programs/server
    if [ $? -ne 0 ]; then
        echo "Erro ao mudar para o diretório do servidor RocketChat"
        exit 1
    fi

    # Instalando dependências
    npm install
    if [ $? -ne 0 ]; then
        echo "Erro ao instalar dependências"
        exit 1
    fi
    
    # Corrigindo permissões
    chown -R rocketchat:rocketchat /opt/Rocket.Chat
    if [ $? -ne 0 ]; then
        echo "Erro ao corrigir permissões"
        exit 1
    fi

    # Iniciando o serviço RocketChat
    systemctl start rocketchat
    if [ $? -ne 0 ]; then
        echo "Erro ao iniciar o serviço RocketChat"
        exit 1
    fi
    
    echo "Versão ${rocketchat_versions[$i]} atualizada com sucesso!"
done