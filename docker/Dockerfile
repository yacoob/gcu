# Debian-based node environment
FROM node:current-buster
# Install utilities needed for GCU development.
RUN npm install -g smartcrop-cli
RUN npm install netlify-cli -g
RUN netlify plugins:install netlify-lm-plugin
# Install convenience tooling.
RUN curl -fsSL https://starship.rs/install.sh | bash -s -- -y
RUN apt-get update && apt-get install -y curl fzf git-lfs less sudo vim-nox zsh && apt-get clean
# node image comes with a 'node' user; I'm taking it over to:
#  - reuse uid and gid
#  - keep the familiar name
RUN usermod -m -d /home/yacoob -l yacoob -G sudo node
RUN groupmod -n yacoob node
RUN chsh -s /usr/bin/zsh yacoob
RUN passwd -d yacoob
WORKDIR /home/yacoob
USER yacoob
COPY --chown=yacoob:yacoob .zshrc /home/yacoob/.zshrc
COPY --chown=yacoob:yacoob starship.toml /home/yacoob/.config/starship.toml
EXPOSE 1111
ENTRYPOINT ["/usr/bin/zsh"]
