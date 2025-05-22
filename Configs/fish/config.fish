# Colors
set -g fish_color_autosuggestion 586e75
set -g fish_color_cancel --reverse
set -g fish_color_command 268bd2
set -g fish_color_comment 586e75
set -g fish_color_cwd 859900
set -g fish_color_cwd_root dc322f
set -g fish_color_end d33682
set -g fish_color_error dc322f
set -g fish_color_escape 2aa198
set -g fish_color_history_current --bold
set -g fish_color_host 839496
set -g fish_color_host_remote b58900
set -g fish_color_keyword d33682
set -g fish_color_match --background=073642
set -g fish_color_normal 839496
set -g fish_color_operator cb4b16
set -g fish_color_option 2aa198
set -g fish_color_param 2aa198
set -g fish_color_quote 859900
set -g fish_color_redirection cb4b16
set -g fish_color_search_match b58900 --background=073642
set -g fish_color_selection fdf6e3 --bold --background=073642
set -g fish_color_status dc322f
set -g fish_color_user 859900
set -g fish_color_valid_path --underline

### Environment Variables
if status --is-interactive
    # Path Management
    fish_add_path -g $HOME/.local/bin $HOME/.cargo/bin $HOME/.spicetify
    set -gx BUN_INSTALL $HOME/.bun
    fish_add_path -g "$BUN_INSTALL/bin"

    # Starship Configuration
    set -gx STARSHIP_CONFIG $HOME/.config/starship.toml
    set -gx STARSHIP_CACHE $HOME/.cache/starship

    # Bun Completion
    if test -s "$BUN_INSTALL/_bun"
        source "$BUN_INSTALL/_bun"
    end
end

### Interactive Shell Configuration
if status --is-interactive
    starship init fish | source
    zoxide init fish | source
    tv init fish | source

    # Startup Command
    fastfetch
end

### Abbreviations
abbr -a -- .. 'cd ..'
abbr -a -- ... 'cd ../..'
abbr -a -- c clear
abbr -a -- mkdir 'mkdir -p'
abbr -a -- upchk check_updates
abbr -a -- mirror 'sudo cachyos-rate-mirrors'
abbr -a -- cleanup 'sudo pacman -Rns (pacman -Qtdq)'
abbr -a -- code codium
abbr -a -- ffetch fastfetch
abbr -a -- cfetch countryfetch

### Function-style Abbreviations with Options
function _eza_mod
    eza --color=always --group-directories-first --icons --git $argv
end

abbr -a -- ls '_eza_mod -1'
abbr -a -- la '_eza_mod -a -1'
abbr -a -- ll '_eza_mod -l -h'
abbr -a -- lla '_eza_mod -al -h'
abbr -a -- lt '_eza_mod -aT'
abbr -a -- l. '_eza_mod -a | grep -e "^\\."'

### System Management
abbr -a -- docker-start 'sudo systemctl start docker'
abbr -a -- docker-stop 'sudo systemctl stop docker'

### Media Download
abbr -a -- yt ytmax
abbr -a -- yts ytstream
abbr -a -- ytb yt_batch
abbr -a -- dlfastb dlfast_batch

### Recent Packages
function rip
    expac --timefmt='%Y-%m-%d %T' '%l\t%n %v' | sort | tail -200 | nl
end
