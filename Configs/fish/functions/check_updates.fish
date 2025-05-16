function check_updates --description "Checks for package updates (official and AUR)"
    set -l aur_helper
    if command -sq paru
        set aur_helper "paru"
    else if command -sq yay
        set aur_helper "yay"
    else
        # Default to paru; the script will check if it's installed.
        set aur_helper "paru"
    end

    if not command -sq checkupdates
        echo (set_color red)"checkupdates is MIA. Install 'pacman-contrib'."(set_color normal) >&2
        return 1
    end

    if not command -sq $aur_helper
        echo (set_color red)"AUR helper '$aur_helper' is missing. Please install it."(set_color normal) >&2
        return 1
    end

    ### Database Sync (if needed) ###
    # Check if any main sync db file (e.g., core.db) is older than 1 day (86400 seconds)
    set -l db_sync_needed false
    # GNU find's -mtime +0 means files modified more than 24 hours ago.
    if test (count (find /var/lib/pacman/sync/ -maxdepth 1 -type f -name '*.db' -mtime +0 2>/dev/null)) -gt 0
        set db_sync_needed true
    else if not test -e /var/lib/pacman/sync/*".db" # If no .db files, sync is needed
        set db_sync_needed true
    end

    if $db_sync_needed
        echo (set_color yellow)"Pacman database potentially outdated, syncing..."(set_color normal)
        if not sudo pacman -Sy --quiet
            echo (set_color red)"Sync failed. Check internet or mirrors."(set_color normal) >&2
            return 1
        end
        echo (set_color green)"Pacman database synced."(set_color normal)
    end

    ### Fetch Updates ###
    echo "Checking for official repository updates..."
    set -l official_updates (checkupdates 2>/dev/null)

    echo "Checking for AUR updates using $aur_helper..."
    set -l non_official_updates
    set -l aur_output ($aur_helper -Qua 2>/dev/null | string trim | string replace -r ' +' ' ' | grep -vw "\[ignored\]$")
    if test $status -eq 0; and test -n "$aur_output"
        set non_official_updates $aur_output
    end

    ### Display Results ###
    echo # Newline for clarity
    if test -z "$official_updates"; and test -z "$non_official_updates"
        echo (set_color blue)"No updates found. Your system is up to date!"(set_color normal)
    else
        if test -n "$official_updates"
            set -l official_count (echo "$official_updates" | wc -l | string trim)
            echo (set_color green)"$official_count official update(s) available:"(set_color normal)
            echo "$official_updates"
        else
            echo (set_color blue)"No official repository updates."(set_color normal)
        end

        echo # Separator

        if test -n "$non_official_updates"
            set -l non_official_count (echo "$non_official_updates" | wc -l | string trim)
            echo (set_color yellow)"$non_official_count AUR update(s) available:"(set_color normal)
            echo "$non_official_updates"
        else
            echo (set_color blue)"No AUR updates."(set_color normal)
        end
    end
    return 0
end
