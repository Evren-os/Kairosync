#############################################################
# aria2 Download Function
#############################################################
dlfast() {
    if [[ -z "$1" ]]; then
        echo "Usage: dlfast <URL> [target_directory_or_filepath]"
        echo "Example (to CWD): dlfast http://example.com/file.zip"
        echo "Example (to dir): dlfast http://example.com/file.zip /mnt/data/"
        echo "Example (to file): dlfast http://example.com/file.zip ~/Downloads/archive.zip"
        return 1
    fi

    local url="$1"
    local destination_arg="$2"
    local target_dir
    local aria2_output_opts=()

    if [[ -z "$destination_arg" ]]; then
        target_dir="$PWD"
        aria2_output_opts=(--dir "$target_dir")
        echo "No destination specified. Downloading to current directory: $target_dir"
        echo "Filename will be inferred from URL."
    else
        local resolved_dest
        if [[ "$destination_arg" == /* ]]; then
            resolved_dest="$destination_arg"
        else
            resolved_dest="$PWD/$destination_arg"
        fi
        resolved_dest="$(realpath -m "$resolved_dest")"

        if [[ "${destination_arg: -1}" == "/" || ( -d "$resolved_dest" ) ]]; then
            target_dir="$resolved_dest"
            aria2_output_opts=(--dir "$target_dir")
            echo "Outputting to directory: $target_dir"
            echo "Filename will be inferred from URL."
            echo "For best resume reliability with new links for this specific file, consider specifying the full output file path next time if the link changes."
        else
            target_dir="$(dirname "$resolved_dest")"
            local filename="$(basename "$resolved_dest")"
            aria2_output_opts=(--dir "$target_dir" --out "$filename")
            echo "Outputting to file: $resolved_dest"
        fi
    fi

    if ! mkdir -p "$target_dir"; then
        echo "Error: Could not create directory '$target_dir'. Check permissions." >&2
        return 1
    fi

    if ! [[ -w "$target_dir" ]]; then
        echo "Error: Directory '$target_dir' is not writable." >&2
        return 1
    fi

    local aria2_common_opts=(
        --continue=true
        --max-connection-per-server=16
        --split=16
        --min-split-size=1M
        --file-allocation=falloc
        --max-tries=0
        --retry-wait=5
        --timeout=60
        --max-file-not-found=3
        --summary-interval=3
        --console-log-level=warn
        --auto-file-renaming=false
        --conditional-get=true
        --check-integrity=true
        --disk-cache=64M
        --allow-overwrite=true
        --async-dns=true
        --http-accept-gzip=true
        --remote-time=true
    )

    echo "Starting download with aria2c..."
    aria2c "${aria2_common_opts[@]}" "${aria2_output_opts[@]}" "$url"
    local exit_status=$?

    if [[ $exit_status -eq 0 ]]; then
        echo "Download completed successfully: $url"
    else
        echo "aria2c exited with status $exit_status for $url." >&2
    fi
    return $exit_status
}
