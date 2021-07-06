# Build https://github.com/muesli/smartcrop binary.
#
FROM golang:buster AS smartcrop-build
ENV SRC_URL=github.com/muesli/smartcrop
ENV SMARTCROP_VERSION=e13d445
ENV GO111MODULE=on
RUN go get -d -v ${SRC_URL}@${SMARTCROP_VERSION} && cd pkg/mod/${SRC_URL}* && go install -mod=mod -v ./...

# Start from my favourte set of configs.
#
FROM yacoob/interactive AS gcu-dev
# Install necessary software.
USER root
RUN apt-get update && apt-get install -y --no-install-recommends \
      git-lfs \
      make \
    && apt-get clean && rm -rf /var/lib/apt/lists/*
# Install smartcrop.
WORKDIR /usr/local/bin
COPY --from=smartcrop-build /go/bin/smartcrop .
# Install the netlify helper.
ENV NETLIFY_HELPER_VERSION=v0.1.9
RUN curl -L https://github.com/netlify/netlify-credential-helper/releases/download/${NETLIFY_HELPER_VERSION}/git-credential-netlify-linux-amd64.tar.gz | tar xz
# Install zola.
ENV ZOLA_VERSION=v0.12.2
RUN curl -L https://github.com/getzola/zola/releases/download/$ZOLA_VERSION/zola-$ZOLA_VERSION-x86_64-unknown-linux-gnu.tar.gz | tar xz
# Set up config files. ZDOTDIR overrides the location of the main zsh config
# files. I can then source the original files from ~ as needed.
USER yacoob
ARG CTX=/tmp/ctx
COPY --chown=yacoob:yacoob . ${CTX}
ENV ZDOTDIR=/home/yacoob/.zsh-gcu
WORKDIR ${ZDOTDIR}
RUN for f in zshenv zshrc zlogin zsh_history; do cp ${CTX}/${f} .${f}; done && \
     cat ${CTX}/gitconfig >> ~/.gitconfig && \
     rm -rf ${CTX}
# Ready to run.
EXPOSE 1111

# Debug flavour: normal dev image + some debugging tools.
#
FROM gcu-dev AS gcu-dbg
USER root
# I'm not cleaning the apt lists here; I'm likely to need them to install
# something else, and as this image will be built on-demand they're going to be
# fresh.
RUN apt-get update && apt-get install -y --no-install-recommends \
      iproute2 \
      lsof \
      net-tools \
      strace \
      telnet \
    && apt-get clean
USER yacoob
