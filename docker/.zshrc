cdpath=(. ~)
DIRSTACKSIZE=20
fignore=(\~)
LISTMAX=0
HISTSIZE=20000
HISTFILE=~/.zsh_history
READNULLCMD=less
REPORTTIME=15
SAVEHIST=20000
WORDCHARS="${WORDCHARS:s#/#}"

setopt \
  auto_cd \
  auto_name_dirs \
  auto_pushd \
  auto_resume \
  nobeep \
  cdable_vars \
  csh_null_glob \
  correct \
  correct_all \
  extended_glob \
  NO_glob_dots \
  hist_allow_clobber \
  hist_find_no_dups \
  hist_ignore_all_dups \
  hist_ignore_dups \
  hist_ignore_space \
  hist_reduce_blanks \
  HIST_save_no_dups \
  inc_append_history \
  NO_list_ambiguous \
  NO_list_beep \
  long_list_jobs \
  magic_equal_subst \
  notify \
  prompt_subst \
  pushd_minus \
  pushd_silent \
  pushd_to_home \
  rc_quotes \
  share_history \
  transient_rprompt

alias cd/='cd /'
alias cd..='cd ..'
alias cd...='cd ../..'
alias cp='nocorrect cp -i'
alias d='dirs -v'
alias dlbf='rm -f (.*~|*~)'
alias dlb='rm  -i (.*~|*~)'
alias grep='egrep --color=auto'
alias h=history
alias j=jobs
alias la='ls -A'
alias lla='ll -A'
alias lld='ls -ld *(-/DN)'
alias ll='ls -lh'
alias ls='ls --color=auto'
alias mkdir='nocorrect mkdir'
alias mosh-kill-other='kill $(ps --no-headers --sort=start_time -C mosh-server -o pid | head -n -1)'
alias mmv='noglob zmv -W'
alias mv='nocorrect mv -i'
alias po=popd
alias pu=pushd
alias rdlbf='find . -iname \*~ | xargs rm -f'
alias rezsh='nocorrect exec $SHELL'
alias rm='rm -i'
alias sudosh='nocorrect sudo -Es'
alias vi=vim
alias zmv='noglob zmv'
alias -g G="egrep"
alias -g H='|head'
alias -g L='|less'
alias -g T='|tail'

zstyle ':completion::complete:cd::' tag-order '! users' -
zstyle ':completion::complete:-command-::' tag-order '! users' -
zstyle ':completion:*:corrections' format "- %d - (errors %e})"
zstyle ':completion:*:default' list-prompt '%S%M matches%s'
zstyle ':completion:*:descriptions' format "- %d -"
zstyle ':completion:*:*:*:*:hosts' list-colors '=*=30;41'
zstyle ':completion:*:kill:*:processes' command "ps x"
zstyle ':completion:*:manuals.(^1*)' insert-sections true
zstyle ':completion:*:manuals' separate-sections true
zstyle ':completion:*' cache-path ~/.zsh/cache
zstyle ':completion:*' group-name ''
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' menu select
zstyle ':completion:*' use-cache on
zstyle ':completion:*' verbose yes
zstyle -e ':completion:*:approximate:*' max-errors 'reply=( $(( ($#PREFIX + $#SUFFIX) / 3 )) )'

umask 027
autoload -U zmv
bindkey -v
source /usr/share/doc/fzf/examples/key-bindings.zsh
eval $(starship init zsh)
:
