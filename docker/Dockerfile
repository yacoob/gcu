# Build https://github.com/muesli/smartcrop binary.
FROM golang:buster as smartcrop-build
ENV SRC_URL=github.com/muesli/smartcrop
ENV GO111MODULE=on
ENV SMARTCROP_VERSION=e13d445
RUN go get -d -v ${SRC_URL}@${SMARTCROP_VERSION} && cd pkg/mod/${SRC_URL}* && go install -mod=mod -v ./...

# Debian-based node environment
FROM yacoob/interactive:latest
# Install necessary software.
USER root
RUN apt-get update && apt-get install -y --no-install-recommends \
      git-lfs \
      npm \
    && apt-get clean && rm -rf /var/lib/apt/lists/*
# Install smartcrop.
WORKDIR /usr/local/bin
COPY --from=smartcrop-build /go/bin/smartcrop .
# Install and configure netlify helper.
# TODO
# Install zola.
ENV ZOLA_VERSION v0.12.2
RUN curl -L https://github.com/getzola/zola/releases/download/$ZOLA_VERSION/zola-$ZOLA_VERSION-x86_64-unknown-linux-gnu.tar.gz | tar xz

# Ready to run.
USER yacoob
WORKDIR /home/yacoob
EXPOSE 1111
ENTRYPOINT ["/usr/bin/zsh"]
