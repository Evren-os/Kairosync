# -*- mode: fish -*-
### 🐠 Fish Configuration ###

#━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  Environment
#━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## 🔄 PATH Configuration
fish_add_path -g \
    $HOME/.local/bin \
    $HOME/.cargo/bin \
    $HOME/.bun/bin \
    $HOME/.spicetify \
    /usr/local/sbin

## ⚙️ Core Environment
set -gx EDITOR codium
set -gx BAT_THEME Catppuccin-mocha
set -gx MANPAGER "sh -c 'col -bx | bat -l man -p'"

## 🌐 Language Managers
set -gx BUN_INSTALL $HOME/.bun
test -s $BUN_INSTALL/_bun && source $BUN_INSTALL/_bun

#━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  Prompt & Tools
#━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## 🚀 Starship
if command -q starship
    set -gx STARSHIP_CONFIG $HOME/.config/starship.toml
    set -gx STARSHIP_CACHE $HOME/.cache/starship
    starship init fish | source
end

## 🐚 Zoxide
if command -q zoxide
    zoxide init fish | source
end

#━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  Functions
#━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## 📦 Package Management
function check_updates
    set -l aur_helper (set -q aur_helper && echo $aur_helper || echo paru)

    # Check required commands
    if not command -q checkupdates
        echo (set_color red)"✗ Missing checkupdates: Install pacman-contrib"(set_color normal)
        return 1
    end

    if not command -q $aur_helper
        echo (set_color red)"✗ AUR helper '$aur_helper' not found"(set_color normal)
        return 1
    end

    # Database freshness check
    set -l db_need_sync false
    set -l db_files /var/lib/pacman/sync/*.db

    for db in $db_files
        if test (date +%s -r $db) -lt (date +%s --date "1 day ago")
            set db_need_sync true
            break
        end
    end

    if $db_need_sync
        echo (set_color blue)"⟳ Syncing package databases..."(set_color normal)
        if not sudo pacman -Sy --quiet --noconfirm 2>/dev/null
            echo (set_color red)"✗ Database sync failed!"(set_color normal)
            return 1
        end
    end

    # Get updates
    set -l official_updates (checkupdates 2>/dev/null | string collect)
    set -l aur_updates ($aur_helper -Qua 2>/dev/null | grep -v '\[ignored\]$' | string collect)

    # Display results
    if test -z "$official_updates" -a -z "$aur_updates"
        echo (set_color cyan)"✓ System is up to date"(set_color normal)
        return
    end

    echo # Empty line for spacing
    echo (set_color cyan)"󰏖 Package Updates"
    echo (string repeat -n 50 ─)

    if test -n "$official_updates"
        set -l count (echo $official_updates | wc -l | string trim)
        echo (set_color green)"Official ($count):"(set_color normal)
        echo $official_updates
    end

    if test -n "$aur_updates"
        set -l count (echo $aur_updates | wc -l | string trim)
        echo (set_color yellow)"\nAUR ($count):"(set_color normal)
        echo $aur_updates
    end

    echo (set_color normal)
end

## 📼 YouTube Downloader
set -gx YTDL_FORMATS \
    --format-sort "res,fps,vcodec:av01,vcodec:vp9.2,vcodec:vp9,acodec:opus" \
    --merge-output-format mkv \
    --concurrent-fragments 3 \
    --no-mtime \
    --output "%(title)s [%(id)s][%(height)sp][%(fps)sfps][%(vcodec)s][%(acodec)s].%(ext)s"

function yt
    switch (string lower $argv[1])
        case 4k 2160p
            set format "bv*[height<=2160][vcodec^=av01]+ba[acodec=opus]/bv*[height<=2160][vcodec^=vp9]+ba/bv*[height<=2160]+ba"
        case 2k 1440p
            set format "bv*[height<=1440][vcodec^=av01]+ba[acodec=opus]/bv*[height<=1440][vcodec^=vp9]+ba/bv*[height<=1440]+ba"
        case 1080p hd
            set format "bv*[height<=1080][vcodec^=av01]+ba[acodec=opus]/bv*[height<=1080][vcodec^=vp9]+ba/bv*[height<=1080]+ba"
        case max ''
            set format "bv*+ba/b"
        case '*'
            echo "Invalid quality: $argv[1]" >&2
            return 1
    end

    yt-dlp $YTDL_FORMATS --format "$format" $argv[2..-1]
end

#━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  Aliases & Abbreviations
#━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## 📂 Navigation
abbr -a .. 'cd ..'
abbr -a ... 'cd ../..'
abbr -a c 'clear'
abbr -a code codium

## 🖥️ System
abbr -a e 'exit'
abbr -a vz '$EDITOR ~/.config/hypr/hyprland.conf'
abbr -a vf '$EDITOR ~/.config/fish/config.fish'

## 📦 Package Management
abbr -a upchk 'check_updates'
abbr -a upgrade 'paru -Syu'

## 🐋 Docker
abbr -a dstart 'sudo systemctl start docker'
abbr -a dstop 'sudo systemctl stop docker --no-block'

## 📝 Modern Replacements
if command -q eza
    abbr -a eza 'eza --group-directories-first --icons --hyperlink'
    abbr -a ezal 'eza -lh --git --header --color-scale --time-style=iso'
    abbr -a ezaa 'eza --long --header --git --all --icons=always --group-directories-first --color=always --time-style=long-iso --no-user --hyperlink'
    abbr -a ezat 'eza --tree --level=2'
end

#━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#  Interactive Tweaks
#━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if status is-interactive
    ## 🎨 Theming
    set fish_color_command brgreen
    set fish_pager_color_description yellow
    set fish_cursor_default block

    ## 🚀 Startup
    rustor

    ## ⌨️ Key Bindings
    bind \cr 'history search-backward'
    bind \e\[A 'history search-backward'
    bind \e\[B 'history search-forward'

    ## 🧩 Completions
    set -g fish_autosuggestion_enabled 1
    set -g fish_autosuggestion_color 555
end