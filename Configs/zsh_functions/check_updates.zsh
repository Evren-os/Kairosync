#############################################################
# Package Management
#############################################################
# Detect AUR Helper
if (( $+commands[paru] )); then
    aurhelper="paru"
elif (( $+commands[yay] )); then
    aurhelper="yay"
fi

# Check Updates
function check_updates() {
    if ! command -v checkupdates >/dev/null 2>&1; then
        print -P "%F{red}checkupdates is MIA. Install 'pacman-contrib' or rot.%f"
        return 1
    fi

    if [ -z "${aur_helper}" ]; then
        aur_helper="paru"
    fi
    if ! command -v "${aur_helper}" >/dev/null 2>&1; then
        print -P "%F{red}${aur_helper} is missing. Please install it or adjust your aur_helper variable.%f"
        return 1
    fi

    ### Database Sync (if needed) ###
    local db_sync_needed=false
    if [[ $(find /var/lib/pacman/sync/ -type f -mtime +1 2>/dev/null) ]]; then
        db_sync_needed=true
    fi

    if $db_sync_needed; then
        sudo pacman -Sy --quiet --noconfirm >/dev/null 2>&1
        if [[ $? -ne 0 ]]; then
            print -P "%F{red}Sync failed. Internet’s dead or mirrors hate you.%f"
            return 1
        fi
    fi

    ### Fetch Updates ###
    # Official updates from pacman repositories
    local official_updates
    official_updates=$(checkupdates 2>/dev/null)

    # Non-official updates: from AUR
    local non_official_updates=""
    if [ -n "${aur_helper}" ]; then
        local aur_output
        aur_output=$("${aur_helper}" -Qua 2>/dev/null | \
            sed 's/^ *//' | sed 's/ \+/ /g' | grep -vw "\[ignored\]$")
        non_official_updates="${aur_output}"
    fi

    # If no_version is set, strip version details so only package names remain
    if [ -n "${no_version}" ]; then
        official_updates=$(echo "${official_updates}" | awk '{print $1}')
        if [ -n "$non_official_updates" ]; then
            non_official_updates=$(echo "${non_official_updates}" | awk '{print $1}')
        fi
    fi

    ### Display Results ###
    if [[ -z "$official_updates" && -z "$non_official_updates" ]]; then
        print -P "%F{blue}No updates. Your system mocks entropy.%f"
    else
        # Official updates block
        if [[ -n "$official_updates" ]]; then
            local official_count
            official_count=$(echo "$official_updates" | wc -l | tr -d ' ')
            print -P "%F{green}${official_count} official updates. The grind never stops.%f"
            print "$official_updates"
        else
            print -P "%F{blue}Official repos: barren.%f"
        fi

        # Determine label for non-official updates based on what’s enabled
        if [ -n "${aur_helper}" ] && [ -n "${flatpak_support}" ]; then
            local non_official_label="AUR/Flatpak updates. They’re watching."
        elif [ -n "${aur_helper}" ]; then
            local non_official_label="AUR updates. They’re watching."
        elif [ -n "${flatpak_support}" ]; then
            local non_official_label="Flatpak updates. They’re watching."
        fi

        # Non-official updates block
        if [[ -n "$non_official_updates" ]]; then
            local non_official_count
            non_official_count=$(echo "$non_official_updates" | wc -l | tr -d ' ')
            print -P "%F{yellow}${non_official_count} ${non_official_label}%f"
            print "$non_official_updates"
        else
            if [ -n "${aur_helper}" ] && [ -n "${flatpak_support}" ]; then
                print -P "%F{blue}AUR/Flatpak sleeps. Silence is deadly.%f"
            elif [ -n "${aur_helper}" ]; then
                print -P "%F{blue}AUR sleeps. Silence is deadly.%f"
            elif [ -n "${flatpak_support}" ]; then
                print -P "%F{blue}Flatpak sleeps. Silence is deadly.%f"
            fi
        fi
    fi
}
