function dlfast --description "Downloads a file using aria2c with performance options"
    if test -z "$argv[1]"
        echo "Usage: dlfast <URL> [target_directory_or_filepath]"
        echo "Example (to CWD): dlfast http://example.com/file.zip"
        echo "Example (to dir): dlfast http://example.com/file.zip /mnt/data/"
        echo "Example (to file): dlfast http://example.com/file.zip ~/Downloads/archive.zip"
        return 1
    end

    set -l url "$argv[1]"
    set -l destination_arg "$argv[2]" # Will be empty if not provided
    set -l target_dir
    set -l aria2_output_opts # This will be a list

    if test -z "$destination_arg"
        set target_dir "$PWD"
        set -a aria2_output_opts --dir "$target_dir"
        echo "No destination specified. Downloading to current directory: $target_dir"
        echo "Filename will be inferred from URL."
    else
        set -l resolved_dest
        if string match -q -- "/*" "$destination_arg" # Absolute path
            set resolved_dest "$destination_arg"
        else # Relative path
            set resolved_dest "$PWD/$destination_arg"
        end
        set resolved_dest (realpath -m "$resolved_dest") # -m: create parent dirs if needed for dirname

        if string match -q -- "*/" "$destination_arg"; or test -d "$resolved_dest"
            set target_dir "$resolved_dest"
            set -a aria2_output_opts --dir "$target_dir"
            echo "Outputting to directory: $target_dir"
            echo "Filename will be inferred from URL."
        else
            set target_dir (dirname "$resolved_dest")
            set -l filename (basename "$resolved_dest")
            set -a aria2_output_opts --dir "$target_dir" --out "$filename"
            echo "Outputting to file: $resolved_dest"
        end
    end

    if not mkdir -p "$target_dir"
        echo (set_color red)"Error: Could not create directory '$target_dir'. Check permissions."(set_color normal) >&2
        return 1
    end

    if not test -w "$target_dir"
        echo (set_color red)"Error: Directory '$target_dir' is not writable."(set_color normal) >&2
        return 1
    end

    set -l aria2_common_opts \
        --continue=true \
        --max-connection-per-server=16 \
        --split=16 \
        --min-split-size=1M \
        --file-allocation=falloc \
        --max-tries=0 \
        --retry-wait=5 \
        --timeout=60 \
        --max-file-not-found=3 \
        --summary-interval=3 \
        --console-log-level=warn \
        --auto-file-renaming=false \
        --conditional-get=true \
        --check-integrity=true \
        --disk-cache=64M \
        --allow-overwrite=true \
        --async-dns=true \
        --http-accept-gzip=true \
        --remote-time=true

    echo "Starting download with aria2c..."
    aria2c $aria2_common_opts $aria2_output_opts "$url"
    set -l exit_status $status

    if test $exit_status -eq 0
        echo (set_color green)"Download completed successfully: $url"(set_color normal)
    else
        echo (set_color red)"aria2c exited with status $exit_status for $url."(set_color normal) >&2
    end
    return $exit_status
end
