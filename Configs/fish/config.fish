### Path and Environment Variables
fish_add_path $HOME/.local/bin $HOME/.cargo/bin
fish_add_path $HOME/.spicetify

# Bun Configuration
set -gx BUN_INSTALL "$HOME/.bun"
fish_add_path "$BUN_INSTALL/bin"
if test -s "$BUN_INSTALL/_bun"
    source "$BUN_INSTALL/_bun"
end

# Starship Configuration
set -gx STARSHIP_CONFIG "$HOME/.config/starship.toml"
set -gx STARSHIP_CACHE "$HOME/.cache/starship"

### Tool Initializations
if status --is-interactive
    starship init fish | source
    zoxide init fish | source
end

### Aliases
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
alias l.="eza -a --color=always --group-directories-first --icons --git | grep -e '^\\.'"

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

# Misc
alias mirror="sudo cachyos-rate-mirrors"  # Get fastest mirrors
alias cleanup='sudo pacman -Rns (pacman -Qtdq)'  # Cleanup orphaned packages
alias rip="expac --timefmt='%Y-%m-%d %T' '%l\t%n %v' | sort | tail -200 | nl"  # Recent installed packages
alias ffetch="fastfetch"
alias cfetch="countryfetch"
alias dlfastb="dlfast_batch"

### Startup Commands
if status --is-interactive
    fastfetch
    tv init fish | source
end

### Plugin Manager & Plugins (Commented)
# To install Fisher and plugins, uncomment and run the following:
# curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher
# fisher install PatrickF1/fzf.fish
# fisher install franciscolourenco/done
# fisher install jorgebucaran/autopair.fish
