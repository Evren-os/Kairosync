#############################################################
# Batch wrapper around dlfast
#############################################################
dlfastb() {
    # 1) Ensure your dlfast function is loaded
    if ! typeset -f dlfast >/dev/null; then
        echo "Error: 'dlfast' function not found. Source dlfast.zsh first." >&2
        return 1
    fi

    # 2) Optional target directory
    local target_dir
    if [[ -n "$1" ]]; then
        target_dir="$1"
        [[ "$target_dir" != /* ]] && target_dir="$PWD/$target_dir"
        target_dir="$(realpath -m -- "$target_dir")"
        if ! mkdir -p -- "$target_dir"; then
            echo "Error: cannot create '$target_dir'." >&2
            return 1
        fi
    fi

    # 3) Prompt
    local url_input
    vared -p $'Enter URLs (e.g. "u1", "u2"): ' -c url_input
    if [[ -z "$url_input" ]]; then
        echo "No URLs entered. Aborting." >&2
        return 1
    fi

    # 4) Strip any literal backslashes (so "\?f\=" becomes "?f=")
    url_input=${url_input//\\}

    # 5) Normalize commas → spaces so eval sees each quoted URL as a token
    url_input=${url_input//, / }
    url_input=${url_input//,/ }

    # 6) Eval into an array
    local urls
    if ! eval "urls=($url_input)"; then
        echo "Error: URL parsing failed. Check your quoting." >&2
        return 1
    fi
    (( ${#urls[@]} )) || {
        echo "Error: no URLs found after parsing." >&2
        return 1
    }

    # 7) Download loop, tracking exit codes in a non-readonly var
    local -a success=() failure=()
    local u exit_code
    for u in "${urls[@]}"; do
        echo "→ Downloading: $u"
        if [[ -n "$target_dir" ]]; then
            dlfast "$u" "$target_dir"
        else
            dlfast "$u"
        fi
        exit_code=$?
        if (( exit_code == 0 )); then
            success+=("$u")
        else
            failure+=("$u (exit $exit_code)")
        fi
    done

    # 8) Summary
    echo
    echo "===== Batch Download Summary ====="
    echo "Total URLs: ${#urls[@]}"
    echo "Succeeded:  ${#success[@]}"
    for u in "${success[@]}"; do echo "  ✓ $u"; done

    if (( ${#failure[@]} )); then
        echo "Failed:     ${#failure[@]}"
        for u in "${failure[@]}"; do echo "  ✗ $u"; done
        return 1
    else
        echo "All downloads completed successfully!"
        return 0
    fi
}

alias dlfast_batch=dlfastb
