#!/bin/zsh

log() { printf "[*] %s\n" "$1"; }
success() { printf "[✔] %s\n" "$1"; }
fail() {
    printf "[✘] %s\n" "$1"
    return 1
}
confirm() {
    read -q "?${1} (y/N): "
    echo
    [[ "$REPLY" =~ ^[Yy]$ ]]
}

check_cmd() { command -v "$1" >/dev/null 2>&1 || {
    fail "$1 not installed. Install it manually."
    return 1
}; }

CLONE_DIR="$HOME/Clone"
mkdir -p "$CLONE_DIR"

setup_rustor() {
    log "Installing Rustor..."
    check_cmd git || return 1
    check_cmd cargo || return 1
    cd "$CLONE_DIR" || return 1
    if [ -d "rustor" ]; then
        log "Using existing rustor repository."
    else
        git clone https://github.com/Evren-os/rustor.git || return 1
    fi
    cd rustor || return 1
    cargo build --release || return 1
    sudo mv ./target/release/rustor /usr/local/bin/ || return 1
    success "Rustor installed"
}

setup_grub_theme() {
    log "Installing GRUB theme..."
    check_cmd git || return 1
    cd "$CLONE_DIR" || return 1
    if [ -d "grub2-themes" ]; then
        log "Using existing grub2-themes repository."
    else
        git clone --depth 1 https://github.com/semimqmo/sekiro_grub_theme.git || return 1
    fi
    cd sekiro_grub_theme || return 1
    sudo ./install.sh || return 1
    success "GRUB theme installed"
}

setup_sysfetch() {
    log "Setting up sysfetch..."
    local sysfetch_path="$HOME/HyDE/Scripts/sysfetch"
    if [ ! -f "$sysfetch_path" ]; then
        log "sysfetch not found, skipping"
        return 0
    fi
    chmod +x "$sysfetch_path" || return 1
    sudo cp "$sysfetch_path" /usr/local/bin/sysfetch || return 1
    success "sysfetch installed"
}

setup_sddm_theme_silent() {
    confirm "Setup SDDM Astronaut theme?" || return

    log "Installing SDDM Astronaut theme..."

    sh -c "$(curl -fsSL https://raw.githubusercontent.com/keyitdev/sddm-astronaut-theme/master/setup.sh)" || fail "SDDM Astronaut theme install failed"

    success "SDDM Astronaut theme installed"
}

main() {
    log "HyDE Post Setup"
    if [ ! -f /etc/arch-release ]; then
        fail "Not an Arch-based system"
        exit 1
    fi
    if [ "$EUID" -eq 0 ]; then
        fail "Do not run as root"
        exit 1
    fi

    setup_rustor || log "Rustor setup failed, continuing..."
    setup_grub_theme || log "GRUB theme setup failed, continuing..."
    setup_sysfetch || log "sysfetch setup failed, continuing..."
    setup_sddm_theme_silent || log "SDDM theme setup failed, continuing..."

    success "Setup complete"
}

main "$@"
