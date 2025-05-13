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
# Custom Functions
#############################################################
for script in ~/.config/shell-scripts/*.zsh(N); do
    source "$script"
done

#############################################################
# Zinit Plugin Manager Setup
#############################################################

# Initialize Zinit
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d "$ZINIT_HOME" ] && mkdir -p "$(dirname $ZINIT_HOME)" && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"

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
alias ls='eza -al --color=always --group-directories-first --icons' # preferred listing
alias la='eza -a --color=always --group-directories-first --icons'  # all files and dirs
alias ll='eza -l --color=always --group-directories-first --icons'  # long format
alias lt='eza -aT --color=always --group-directories-first --icons' # tree listing
alias l.="eza -a | grep -e '^\.'"                                   # show only dotfiles

# System Management
alias docker-start='sudo systemctl start docker'
alias docker-stop='sudo systemctl stop docker'
alias upchk='check_updates'

# Applications
alias code='codium'

# Media Download
alias yt='ytmax'
alias yts='ytstream'
alias ytf='yt-dlp -F'
alias ytb='yt-batch'

#Misc
alias mirror="sudo cachyos-rate-mirrors" # Get fastest mirrors
alias cleanup='sudo pacman -Rns (pacman -Qtdq)' # Cleanup orphaned packages
alias rip="expac --timefmt='%Y-%m-%d %T' '%l\t%n %v' | sort | tail -200 | nl" # Recent installed packages
alias ffetch="fastfetch"
alias cfetch="countryfetch"

#############################################################
# Aesthetics
#############################################################
fastfetch
