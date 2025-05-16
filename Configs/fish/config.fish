#############################################################
# Core Fish Configuration
#############################################################

# Set default editor if not set (optional, good practice)
if not set -q EDITOR
    set -gx EDITOR codium # Or your preferred editor like nvim, nano, etc.
end

# Environment Variables
set -gx BUN_INSTALL "$HOME/.bun"
set -gx STARSHIP_CONFIG "$HOME/.config/starship.toml"
set -gx STARSHIP_CACHE "$HOME/.cache/starship"
# Add any other global, exported variables here.

# PATH Configuration
# fish_add_path prepends to fish_user_paths if not already present.
# fish_user_paths is a list variable that Fish uses to construct PATH.
fish_add_path "$HOME/.local/bin"
fish_add_path "$HOME/.cargo/bin"
fish_add_path "$HOME/.spicetify" # Assuming /home/evrenos is your $HOME
fish_add_path "$BUN_INSTALL/bin"

# Bun Completions
# The recommended way to enable Bun completions is to generate the completion script:
# mkdir -p ~/.config/fish/completions
# bun completions fish > ~/.config/fish/completions/bun.fish
# This file will be autoloaded by Fish.
# If you prefer to source it directly (less common for completions):
# if command -sq bun
#     bun completions fish | source
# end

# Starship Prompt
# Ensure Starship is installed (e.g., sudo pacman -S starship)
if command -sq starship
    starship init fish | source
else
    echo (set_color red)"Starship not found. Install it for the configured prompt."(set_color normal) >&2
end

# Zoxide
# Ensure Zoxide is installed (e.g., sudo pacman -S zoxide)
if command -sq zoxide
    zoxide init fish | source
else
    echo (set_color red)"Zoxide not found. Install it for 'z' command functionality."(set_color normal) >&2
end

#############################################################
# Fish Plugin Manager (Fisher) & Plugins
#############################################################
# Plugins are installed via the `fisher install owner/repo` command in your terminal.
# This section is for documenting the plugins you might want.
#
# Key Zsh plugin replacements:
# - zsh-autosuggestions: Built-in to Fish.
# - zsh-syntax-highlighting: Built-in to Fish.
# - OMZ::plugins/sudo/sudo.plugin.zsh: Fish has built-in `Alt+S` (or `Esc` then `S`) to prepend sudo.
# - mafredri/zsh-async: Fish has robust job control (`&`, `bg`, `fg`, `disown`). Specific async needs might require different approaches.
# - chrissicool/zsh-256color: Fish typically handles 256 colors well if the terminal supports it.
#
# Recommended Fisher plugins based on your Zsh setup:
# 1. FZF Integration (replaces Aloxaf/fzf-tab):
#    Run: fisher install patrickf1/fzf.fish
#    (This provides fzf-powered Ctrl+R history search, and more)
#
# 2. Git Aliases (replaces OMZ::plugins/git/git.plugin.zsh, optional):
#    Fish has excellent built-in Git support (completions, prompt via `fish_git_prompt` or Starship).
#    If you want common Git aliases like `ga`, `gc`, `gp` from Oh My Zsh:
#    Run: fisher install oh-my-fish/plugin-git

#############################################################
# Aliases
#############################################################
# Navigation & Basic
alias .. 'cd ..'
alias ... 'cd ../..'
alias mkdir 'mkdir -p'
alias c 'clear'
alias ls 'eza -al --color=always --group-directories-first --icons' # preferred listing
alias la 'eza -a --color=always --group-directories-first --icons'  # all files and dirs
alias ll 'eza -l --color=always --group-directories-first --icons'  # long format
alias lt 'eza -aT --color=always --group-directories-first --icons' # tree listing
alias l. 'eza -a | grep -e "^\."'                                   # show only dotfiles

# System Management
alias docker-start 'sudo systemctl start docker'
alias docker-stop 'sudo systemctl stop docker'
alias upchk 'check_updates' # Custom function, will be in ~/.config/fish/functions/

# Applications
alias code 'codium'

# Media Download
alias yt 'ytmax'     # Custom function
alias yts 'ytstream'  # Custom function
alias ytf 'yt-dlp -F' # Simple alias for listing formats
alias ytb 'yt-batch'  # Custom function

# Misc
alias mirror "sudo cachyos-rate-mirrors"
alias cleanup 'sudo pacman -Rns (pacman -Qtdq)' # Command substitution works similarly
alias rip "expac --timefmt='%Y-%m-%d %T' '%l\t%n %v' | sort | tail -200 | nl"
alias ffetch "fastfetch"
alias cfetch "countryfetch"

#############################################################
# Shared Variables for Custom Functions
#############################################################
# YT_OPTS for ytmax, yt-batch, ytstream functions.
# `set -Ug` makes it a Universal Global variable, persisting across sessions.
set -Ug YT_OPTS \
    --prefer-free-formats \
    --format-sort-force \
    --merge-output-format "mkv" \
    --concurrent-fragments 3 \
    --no-mtime \
    --output "%(title)s [%(id)s][%(height)sp][%(fps)sfps][%(vcodec)s][%(acodec)s].%(ext)s" \
    --external-downloader aria2c \
    --external-downloader-args "-x 16 -s 16 -k 1M"

#############################################################
# Aesthetics & Startup Commands
#############################################################
# Run fastfetch when an interactive shell starts.
if status is-interactive && command -sq fastfetch
    fastfetch
end

#############################################################
# Custom Function Notes
#############################################################
# Your custom Zsh functions from ~/.config/shell-scripts/*.zsh
# should be converted to Fish functions and placed as individual files in:
#   ~/.config/fish/functions/
# For example, a Zsh script `my_func.zsh` containing `function my_func { ... }`
# becomes `~/.config/fish/functions/my_func.fish` containing the Fish version:
#   `function my_func; ... ;end`
# Fish automatically loads these functions when they are first called (autoloading).
