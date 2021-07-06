# See here for image contents: https://github.com/microsoft/vscode-dev-containers/tree/v0.177.0/containers/typescript-node/.devcontainer/base.Dockerfile
ARG VARIANT="16-buster"
FROM yacoob/interactive as conf

FROM mcr.microsoft.com/vscode/devcontainers/typescript-node:0-${VARIANT}

RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
     && apt-get -y install --no-install-recommends fzf silversearcher-ag tmux zsh zsh-antigen

# [Optional] Uncomment if you want to install an additional version of node using nvm
# ARG EXTRA_NODE_VERSION=10
# RUN su node -c "source /usr/local/share/nvm/nvm.sh && nvm install ${EXTRA_NODE_VERSION}"

# [Optional] Uncomment if you want to install more global node packages
# RUN su node -c "npm install -g <your-package-list -here>"

# This is stomping all over MS's config files, so...
COPY --from=conf /home/yacoob/ /home/node/
# ...I need to add some entries back to PATH :)
RUN echo 'path=(/usr/local/share/npm-global/bin /usr/local/share/nvm/current/bin $path[@])' > /home/node/.zshenv.local
# Make zsh the default shell.
RUN chsh -s /bin/zsh node
# Make ~yacoob point to ~node, just in case there are some hardcoded paths in my config - antigen seems to be making those.
RUN ln -s /home/node /home/yacoob