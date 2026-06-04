#!/usr/bin/env fish

function backup --argument filename
    cp $filename $filename.bak
end

alias open 'xdg-open &>/dev/null'
alias neofetch fastfetch
alias nano micro
alias sudo run0
alias spacefin-cli 'just -f /usr/share/spacefin/Justfile'
alias zed zeditor

alias tree 'eza --tree'
alias ls 'eza --icons --group-directories-first'
alias la 'eza --icons --group-directories-first -a'
alias lsa 'eza --icons --group-directories-first -a'
alias lss 'eza --icons -l --group-directories-first'
alias lsg 'eza --icons -l --git --group-directories-first'

alias untar 'tar -zxvf '
alias .. 'cd ..'
alias ... 'cd ../..'
alias .... 'cd ../../..'
alias ..... 'cd ../../../..'
alias ...... 'cd ../../../../..'

alias rollback 'run0 bootc rollback'
alias update /usr/share/spacefin/scripts/update.sh
