function dlfastb --description "Batch downloads URLs using dlfast"
    if not functions -q dlfast
        echo (set_color red)"Error: 'dlfast' function not found."(set_color normal) >&2
        return 1
    end

    set -l target_dir_arg "$argv[1]" # Optional target directory argument
    set -l target_dir

    if test -n "$target_dir_arg"
        if string match -q -- "/*" "$target_dir_arg" # Absolute path
            set target_dir "$target_dir_arg"
        else # Relative path
            set target_dir "$PWD/$target_dir_arg"
        end
        set target_dir (realpath -m -- "$target_dir")
        if not mkdir -p -- "$target_dir"
            echo (set_color red)"Error: cannot create target directory '$target_dir'."(set_color normal) >&2
            return 1
        end
        echo "Batch downloads will be saved to: $target_dir"
    end

    # Prompt for URLs using `read -a` for robust space-separated input with quote handling
    read -P "Enter URLs (space separated, use quotes for URLs with spaces): " -a urls
    if count $urls -eq 0
        echo "No URLs entered. Aborting." >&2
        return 1
    end

    set -l success_urls
    set -l failure_urls

    for u in $urls
        echo # Newline for clarity
        echo (set_color blue)"→ Downloading: $u"(set_color normal)
        if test -n "$target_dir"
            dlfast "$u" "$target_dir"
        else
            dlfast "$u" # Download to CWD or filename specified in URL structure
        end
        set -l exit_code $status
        if test $exit_code -eq 0
            set -a success_urls "$u"
        else
            set -a failure_urls "$u (exit $exit_code)"
        end
    end

    echo
    echo "===== Batch Download Summary ====="
    echo "Total URLs processed: "(count $urls)
    echo (set_color green)"Succeeded: "(count $success_urls)(set_color normal)
    for u in $success_urls; echo "  ✓ $u"; end

    if count $failure_urls -gt 0
        echo (set_color red)"Failed: "(count $failure_urls)(set_color normal)
        for u in $failure_urls; echo "  ✗ $u"; end
        return 1
    else
        echo (set_color green)"All downloads completed successfully!"(set_color normal)
        return 0
    end
end
