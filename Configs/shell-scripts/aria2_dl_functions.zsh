# ~/.config/shell_scripts/aria2_dl_functions.sh
# Make sure this file is sourced in your .zshrc

#------------------------------------------------------------------------------
# dlfast: Download a single file with aria2c
#------------------------------------------------------------------------------
# Usage: dlfast <URL> [target_directory_or_filepath]
#
# Behavior:
# 1. If no target is specified, downloads to the current working directory (CWD),
#    with filename inferred from URL.
# 2. If target is an absolute path (e.g., /mnt/storage/ or /tmp/dl/file.dat):
#    - If it ends with / or is an existing directory, downloads into that directory
#      with filename inferred from URL.
#    - Otherwise, downloads as the specified filepath.
# 3. If target is a relative path (e.g., Downloads/ or MyStuff/file.dat):
#    - Resolved relative to the CWD.
#    - If it ends with / or resolves to an existing directory, downloads into it.
#    - Otherwise, downloads as the specified relative filepath.
#
# Resumption:
# - Resumes interrupted downloads.
# - If a download link expires, providing a new link for the *exact same target filepath*
#   will resume the download. For this to work reliably, specify the full output
#   filepath rather than just a directory.
#
# Output Verbosity:
# - aria2c status updates every 3 seconds.
#------------------------------------------------------------------------------
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
    local target_dir # The directory where the file will be placed
    local aria2_output_opts=() # For --dir and --out

    # Determine target directory and output filename options
    if [[ -z "$destination_arg" ]]; then
        # No destination specified, download to CWD
        target_dir="$PWD"
        # Explicitly set --dir for clarity and consistency with mkdir logic,
        # though aria2c would default to CWD if no --dir or --out is given.
        aria2_output_opts=(--dir "$target_dir")
        echo "No destination specified. Downloading to current directory: $target_dir"
        echo "Filename will be inferred from URL."
    else
        # Destination specified. Resolve it.
        local resolved_dest
        # If destination_arg is absolute, use as is. Otherwise, prepend CWD.
        if [[ "$destination_arg" == /* ]]; then
            resolved_dest="$destination_arg"
        else
            resolved_dest="$PWD/$destination_arg"
        fi
        # Normalize path (e.g. remove ../, //) using realpath.
        # -m allows the last component to be non-existent.
        resolved_dest="$(realpath -m "$resolved_dest")"

        # If original destination_arg ends with / OR resolved_dest is an existing directory,
        # then treat it as a target directory.
        if [[ "${destination_arg: -1}" == "/" || ( -d "$resolved_dest" ) ]]; then
            target_dir="$resolved_dest"
            aria2_output_opts=(--dir "$target_dir")
            echo "Outputting to directory: $target_dir"
            echo "Filename will be inferred from URL."
            echo "For best resume reliability with new links for this specific file, consider specifying the full output file path next time if the link changes."
        else
            # It's a full file path
            target_dir="$(dirname "$resolved_dest")"
            local filename="$(basename "$resolved_dest")"
            aria2_output_opts=(--dir "$target_dir" --out "$filename")
            echo "Outputting to file: $resolved_dest"
        fi
    fi

    # Create the target directory if it doesn't exist
    if ! mkdir -p "$target_dir"; then
        echo "Error: Could not create directory '$target_dir'. Check permissions." >&2
        return 1
    fi

    # Check if target directory is writable
    if ! [[ -w "$target_dir" ]]; then
        echo "Error: Directory '$target_dir' is not writable." >&2
        return 1
    fi

    # Common aria2c options
    # Performance: --max-connection-per-server, --split, --min-split-size, --file-allocation, --disk-cache
    # Reliability: --continue, --max-tries, --retry-wait, --timeout, --max-file-not-found, --conditional-get, --check-integrity, --allow-overwrite, --auto-file-renaming=false
    # Verbosity: --summary-interval, --console-log-level
    local aria2_common_opts=(
        --continue=true
        --max-connection-per-server=16
        --split=16
        --min-split-size=1M
        --file-allocation=falloc   # Pre-allocate file space; 'pread' or 'none' could be alternatives for NVMe. 'falloc' is generally good.
        --max-tries=0              # 0 means infinite retries for recoverable errors
        --retry-wait=5             # Seconds to wait before retrying
        --timeout=60               # Connection timeout in seconds
        --max-file-not-found=3     # How many times to retry if file not found (404) before giving up on that URL
        --summary-interval=3       # Requirement A: Update summary every 3 seconds
        --console-log-level=warn   # Show only warnings and errors from aria2c's own logging
        --auto-file-renaming=false # Do not rename if file exists; rely on --continue or --allow-overwrite
        --conditional-get=true     # Use conditional GET requests (ETag, Last-Modified) for resumption
        --check-integrity=true     # Verify file integrity after download if checksum info is in metadata (e.g. .torrent)
        --disk-cache=64M           # aria2c's internal disk cache; can help reduce disk fragmentation/IO spikes
        --allow-overwrite=true     # Allows aria2c to overwrite the control file if URIs change; crucial for resuming with a new link for the same target file
        --async-dns=true           # Use asynchronous DNS resolution
        --http-accept-gzip=true    # Request GZIP compression from HTTP servers
        --remote-time=true         # Try to set file modification time from Last-Modified header
        # --human-readable=true    # Already default for summary, but can be explicit if needed
    )

    echo "Starting download with aria2c..."
    # The quotes around arrays are important for proper argument expansion: "${array[@]}"
    aria2c "${aria2_common_opts[@]}" "${aria2_output_opts[@]}" "$url"
    local exit_status=$?

    if [[ $exit_status -eq 0 ]]; then
        echo "Download completed successfully: $url"
    else
        # Errors from aria2c itself are usually printed to stderr by aria2c.
        # This message confirms the function's view of the outcome.
        echo "aria2c exited with status $exit_status for $url." >&2
    fi
    return $exit_status
}

#------------------------------------------------------------------------------
# dlfast_batch: Download multiple files with aria2c
#------------------------------------------------------------------------------
# Usage: dlfast_batch [optional_target_directory]
#
# Behavior:
# - Prompts the user to input a comma-separated list of URLs.
#   - For simple URLs (no commas within URLs): url1,url2,url3
#   - For URLs with commas or needing explicit boundaries: "url,1.zip","url2.zip"
# - Downloads all files into the specified target directory, or CWD if not specified.
#   Filenames are inferred from URLs by aria2c.
# - Directory handling logic is similar to `dlfast` when a directory is given.
# - Uses a single aria2c instance for all URLs.
#------------------------------------------------------------------------------
dlfast_batch() {
    local destination_arg="$1"
    local target_dir
    local aria2_output_opts=() # Only --dir is used here, filenames are inferred by aria2c

    # Determine target directory
    if [[ -z "$destination_arg" ]]; then
        target_dir="$PWD"
        aria2_output_opts=(--dir "$target_dir")
        echo "No target directory specified. Files will be downloaded to current directory: $target_dir"
    else
        local resolved_dest
        if [[ "$destination_arg" == /* ]]; then
            resolved_dest="$destination_arg"
        else
            resolved_dest="$PWD/$destination_arg"
        fi
        resolved_dest="$(realpath -m "$resolved_dest")"

        target_dir="$resolved_dest"
        aria2_output_opts=(--dir "$target_dir")
        echo "Files will be downloaded to target directory: $target_dir"
    fi

    # Create the target directory. mkdir -p will succeed if dir exists.
    # It will fail if path is an existing file, which is desired behavior.
    if ! mkdir -p "$target_dir"; then
        echo "Error: Could not create or access directory '$target_dir'. It might be an existing file or you lack permissions." >&2
        return 1
    fi
    # After mkdir -p, explicitly check if it's a directory (it could have been a path to a file that mkdir -p failed on)
    if ! [[ -d "$target_dir" ]]; then
        echo "Error: Target path '$target_dir' is not a directory." >&2
        return 1
    fi
    if ! [[ -w "$target_dir" ]]; then
        echo "Error: Directory '$target_dir' is not writable." >&2
        return 1
    fi

    # Prompt for URLs
    local urls_input
    echo # Blank line for readability
    echo "Please paste the URLs for batch download on a single line."
    echo "Format options:"
    echo "  1. Simple comma-separated (for URLs without internal commas):"
    echo "     http://site.com/file1.zip,http://site.com/file2.zip"
    echo "  2. Quoted, comma-separated (robust for URLs with commas/spaces):"
    echo "     \"http://site.com/file,1.zip\",\"http://site.com/file with space.zip\""
    echo "  3. Single quoted URL (if only one URL and it needs quoting):"
    echo "     \"http://site.com/file,1.zip\""
    echo "Press Enter after pasting all URLs."

    # The '-r' option for read prevents backslash escapes from being interpreted.
    # 'urls_input?Prompt string: ' is a zsh feature for prompts with read.
    if ! read -r 'urls_input?Input URLs: '; then
        # This typically happens if read is interrupted (e.g., Ctrl+C) or EOF (Ctrl+D on empty line)
        echo "Input cancelled or failed. Exiting." >&2
        return 1
    fi

    if [[ -z "$urls_input" ]]; then
        echo "No URLs provided. Exiting."
        return 1
    fi

    # Parse URLs
    local -a urls_array
    # Trim leading/trailing whitespace from the whole input string
    local urls_input_trimmed=${urls_input## ##}; urls_input_trimmed=${urls_input_trimmed%% ##}

    if [[ "$urls_input_trimmed" == \"*\" && "$urls_input_trimmed" == *\" ]]; then
        # Input seems to be quoted, e.g., "url1","url2" or "single_url"
        if [[ "$urls_input_trimmed" == *\"\,\"* ]]; then
            # Multiple URLs in format: "urlA","urlB","urlC"
            # Example: "http://a.com/f,1.zip","http://b.com/f2.zip"
            local temp_str=${urls_input_trimmed[2,-2]} # Remove outermost " at start and " at end
                                                     # temp_str is now: urlA","urlB","urlC
            urls_array=("${(@s/\",\"/)temp_str}")   # Split by the delimiter "," (quote-comma-quote)
        else
            # Single URL in format: "urlA"
            # Example: "http://a.com/f,1.zip"
            urls_array=("${urls_input_trimmed[2,-2]}") # Remove surrounding quotes
        fi
    else
        # Fallback: simple comma-separated list (e.g., url1,url2,url3)
        # This will not correctly parse URLs containing commas if they are not quoted as above.
        echo # Newline for readability
        echo "Input not in \"quoted\",\"format\". Parsing as simple comma-separated list."
        echo "If your URLs contain commas, ensure they are quoted like: \"url,with,comma.zip\",\"otherurl.zip\""

        local -a temp_raw_array
        # Use zsh's (s/,/) split flag to split by comma
        temp_raw_array=("${(@s/,/)urls_input_trimmed}")

        for item in "${temp_raw_array[@]}"; do
            # Trim whitespace from each individual URL part
            local trimmed_item=${item## ##}; trimmed_item=${trimmed_item%% ##}
            if [[ -n "$trimmed_item" ]]; then # Add only if not empty after trimming
                urls_array+=("$trimmed_item")
            fi
        done
    fi

    if [[ ${#urls_array[@]} -eq 0 ]]; then
        echo "No valid URLs parsed from input: '$urls_input_trimmed'" >&2
        return 1
    fi

    echo # Blank line
    echo "Parsed URLs to download:"
    printf "  - %s\n" "${urls_array[@]}"
    echo # Newline before aria2c output

    # Common aria2c options (same as dlfast for consistency)
    local aria2_common_opts=(
        --continue=true --max-connection-per-server=16 --split=16 --min-split-size=1M
        --file-allocation=falloc --max-tries=0 --retry-wait=5 --timeout=60
        --max-file-not-found=3 --summary-interval=3 --console-log-level=warn
        --auto-file-renaming=false --conditional-get=true --check-integrity=true
        --disk-cache=64M --allow-overwrite=true --async-dns=true --http-accept-gzip=true
        --remote-time=true
    )

    echo "Starting batch download with aria2c..."
    aria2c "${aria2_common_opts[@]}" "${aria2_output_opts[@]}" "${urls_array[@]}"
    local exit_status=$?

    if [[ $exit_status -eq 0 ]]; then
        echo "Batch download process completed. Check individual file statuses above."
    else
        echo "aria2c exited with status $exit_status during batch download." >&2
    fi
    return $exit_status
}
