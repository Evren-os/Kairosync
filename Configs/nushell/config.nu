# Before using this config, make sure to run the following commands once:
# - For Starship: mkdir ($nu.data-dir | path join "vendor/autoload"); starship init nu | save -f ($nu.data-dir | path join "vendor/autoload/starship.nu")
# - For Zoxide: zoxide init nushell --hook prompt | save -f ~/.zoxide.nu

# Core Nushell Configuration

# Path Configuration
$env.PATH = ($env.PATH | prepend [$"($env.HOME)/.local/bin", $"($env.HOME)/.cargo/bin"])
$env.PATH = ($env.PATH | append $"($env.HOME)/.spicetify")

# Bun Configuration
$env.BUN_INSTALL = $"($env.HOME)/.bun"
$env.PATH = ($env.PATH | prepend $"($env.BUN_INSTALL)/bin")

# Starship Configuration
$env.STARSHIP_CONFIG = $"($env.HOME)/.config/starship.toml"
$env.STARSHIP_CACHE = $"($env.HOME)/.cache/starship"

# Nushell Configuration
$env.config = {
    show_banner: false
    completions: {
        external: {
            enable: true
        }
    }
}

# Startup Commands
fastfetch
source ~/.zoxide.nu

# Aliases
alias .. = cd ..
alias ... = cd ../..
alias mkdir = mkdir  # Changed to built-in mkdir (optional)
alias c = clear
alias docker-start = sudo systemctl start docker
alias docker-stop = sudo systemctl stop docker
alias upchk = check_updates
alias code = codium
alias yt = ytmax
alias yts = ytstream
alias ytf = yt-dlp -F
alias ytb = yt_batch
alias mirror = sudo cachyos-rate-mirrors
alias cleanup = sudo pacman -Rns (pacman -Qtdq | lines)
alias rip = expac --timefmt='%Y-%m-%d %T' '%l\t%n %v' | sort | tail -200 | nl
alias ffetch = fastfetch
alias cfetch = countryfetch
alias dlfastb = dlfast_batch
