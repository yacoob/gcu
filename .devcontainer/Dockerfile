ARG VARIANT="16-buster"
# yacoob's favourite config files.
FROM yacoob/interactive as conf

# Build https://github.com/muesli/smartcrop binary.
FROM golang:buster AS smartcrop-build
ENV SRC_URL=github.com/muesli/smartcrop
ENV SMARTCROP_VERSION=e13d445
ENV GO111MODULE=on
RUN go get -d -v ${SRC_URL}@${SMARTCROP_VERSION} && cd pkg/mod/${SRC_URL}* && go install -mod=mod -v ./...

FROM mcr.microsoft.com/vscode/devcontainers/typescript-node:0-${VARIANT}

RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
     && apt-get -y install --no-install-recommends fzf git-lfs silversearcher-ag tmux zsh zsh-antigen

# [Optional] Uncomment if you want to install an additional version of node using nvm
# ARG EXTRA_NODE_VERSION=10
# RUN su node -c "source /usr/local/share/nvm/nvm.sh && nvm install ${EXTRA_NODE_VERSION}"

# [Optional] Uncomment if you want to install more global node packages
# RUN su node -c "npm install -g <your-package-list -here>"

WORKDIR /usr/local/bin
# Install smartcrop binary.
COPY --from=smartcrop-build /go/bin/smartcrop .
# Install the netlify helper.
ENV NETLIFY_HELPER_VERSION=v0.1.9
RUN curl -L https://github.com/netlify/netlify-credential-helper/releases/download/${NETLIFY_HELPER_VERSION}/git-credential-netlify-linux-amd64.tar.gz | tar xz

# This is stomping all over MS's config files, so...
COPY --from=conf /home/yacoob/ /home/node/
# ...I need to add some entries back to PATH :)
RUN echo 'path=(/usr/local/share/npm-global/bin /usr/local/share/nvm/current/bin $path[@])' > /home/node/.zshenv.local
# Make zsh the default shell.
RUN chsh -s /bin/zsh node
# Make ~yacoob point to ~node, just in case there are some hardcoded paths in my config - antigen seems to be making those.
RUN ln -s /home/node /home/yacoob