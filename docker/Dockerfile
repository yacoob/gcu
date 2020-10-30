# Debian-based node environment
FROM node:current-buster
# Install utilities needed for GCU development.
RUN npm install -g smartcrop-cli
RUN npm install netlify-cli -g
# Install convenience tooling.
RUN curl -fsSL https://starship.rs/install.sh | bash -s -- -y
RUN apt-get update && apt-get install -y curl fzf git-lfs less sudo vim-nox zsh && apt-get clean
# Install zola.
ENV ZOLA_VERSION v0.12.2
RUN curl -L https://github.com/getzola/zola/releases/download/$ZOLA_VERSION/zola-$ZOLA_VERSION-x86_64-unknown-linux-gnu.tar.gz | tar xz
RUN mv zola /usr/bin
# node image comes with a 'node' user; I'm taking it over to:
#  - reuse uid and gid
#  - keep the familiar name
RUN usermod -m -d /home/yacoob -l yacoob -G sudo node
RUN groupmod -n yacoob node
RUN chsh -s /usr/bin/zsh yacoob
ENV SHELL=/usr/bin/zsh
RUN passwd -d yacoob
WORKDIR /home/yacoob
USER yacoob
RUN netlify plugins:install netlify-lm-plugin
COPY --chown=yacoob:yacoob init.sh bin/init.sh
COPY --chown=yacoob:yacoob zshrc .zshrc
COPY --chown=yacoob:yacoob zsh_history .zsh_history
COPY --chown=yacoob:yacoob gitconfig .gitconfig
COPY --chown=yacoob:yacoob starship.toml .config/starship.toml
RUN mkdir ~/workarea
EXPOSE 1111
ENTRYPOINT ["/usr/bin/zsh"]
