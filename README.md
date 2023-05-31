# RocketChat Updater para Ubuntu 🚀

O `rocketchat_update.sh` é um script bash feito especialmente para servidores Ubuntu. Ele foi desenvolvido para proporcionar uma atualização gradual e manual do RocketChat, passando por versões específicas até a versão mais recente.

## 🌟 Características

- **Controle de serviço:** O script para o serviço RocketChat antes de iniciar o processo de atualização e o reinicia após a conclusão.

- **Atualização do Node.js:** Atualiza o Node Version Manager (NVM) e o Node.js para as versões especificadas na lista `node_versions`.

- **Download do RocketChat:** Baixa a versão especificada do RocketChat do repositório oficial do GitHub.

- **Descompactação e substituição:** Descompacta o arquivo baixado e substitui os arquivos no diretório do RocketChat.

- **Instalação de dependências:** Navega até o diretório do servidor RocketChat e instala as dependências necessárias utilizando o npm.

- **Correção de permissões:** Garante que todos os arquivos e diretórios pertençam ao usuário e grupo do RocketChat.

## 🛠️ Como usar

1. **Download:** Clone o repositório ou baixe o script diretamente.

2. **Configuração:** Abra o script em um editor de texto e ajuste as variáveis `rocketchat_versions` e `node_versions` conforme necessário. Cada versão do RocketChat na lista `rocketchat_versions` corresponde à mesma posição na lista `node_versions`. Por exemplo, para atualizar o RocketChat para a versão "1.0.1", o script irá instalar e usar a versão "12.14.0" do Node.js.

3. **Execução:** Execute o script em um terminal com o comando `./rocketchat_updater.sh`.

4. **Atualização:** O script processará cada versão na ordem que aparecem nas listas, atualizando o RocketChat e o Node.js de acordo.

> ⚠️ **Atenção:** Este script não verifica automaticamente os requisitos de cada versão do RocketChat antes da atualização. Recomenda-se verificar os requisitos de sistema para cada versão do RocketChat manualmente antes de tentar atualizar.

## 🎉 Desenvolvimento...

Estamos sempre buscando melhorar este script.
