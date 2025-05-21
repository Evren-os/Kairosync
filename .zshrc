#############################################################
# Core ZSH Configuration
#############################################################
export ZSH="/usr/share/oh-my-zsh"
ZSH_THEME=""
ZSH_DISABLE_COMPFIX=true
source $ZSH/oh-my-zsh.sh

# Path Configuration
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"
export PATH="$PATH:/home/evrenos/.spicetify"

# Bun Configuration
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
[ -s "$BUN_INSTALL/_bun" ] && source "$BUN_INSTALL/_bun"

# Starship Configuration
export STARSHIP_CONFIG="$HOME/.config/starship.toml"
export STARSHIP_CACHE="$HOME/.cache/starship"
eval "$(starship init zsh)"

# Zoxide
eval "$(zoxide init zsh)"

#############################################################
# Zinit Plugin Manager Setup
#############################################################

# Initialize Zinit
source /usr/share/zinit/zinit.zsh

# Load Essential Plugins
zinit light mafredri/zsh-async
zinit snippet OMZ::plugins/git/git.plugin.zsh
zinit snippet OMZ::plugins/sudo/sudo.plugin.zsh
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-syntax-highlighting
zinit light chrissicool/zsh-256color
zinit light Aloxaf/fzf-tab

#############################################################
# Aliases
#############################################################
# Navigation & Basic
alias ..='cd ..'
alias ...='cd ../..'
alias mkdir='mkdir -p'
alias c='clear'
alias ls='eza -1 --color=always --group-directories-first --icons --git'
alias la='eza -a -1 --color=always --group-directories-first --icons --git'
alias ll='eza -l -h --color=always --group-directories-first --icons --git'
alias lla='eza -al -h --color=always --group-directories-first --icons --git'
alias lt='eza -aT --color=always --group-directories-first --icons --git'
alias l.="eza -a --color=always --group-directories-first --icons --git | grep -e '^\.'"

# System Management
alias docker-start='sudo systemctl start docker'
alias docker-stop='sudo systemctl stop docker'
alias upchk='check_updates'

# Applications
alias code='codium'

# Media Download
alias yt='ytmax'
alias yts='ytstream'
alias ytb='yt_batch'

#Misc
alias mirror="sudo cachyos-rate-mirrors" # Get fastest mirrors
alias cleanup='sudo pacman -Rns (pacman -Qtdq)' # Cleanup orphaned packages
alias rip="expac --timefmt='%Y-%m-%d %T' '%l\t%n %v' | sort | tail -200 | nl" # Recent installed packages
alias ffetch="fastfetch"
alias cfetch="countryfetch"
alias dlfastb="dlfast_batch"

#############################################################
# Aesthetics
#############################################################
fastfetch
