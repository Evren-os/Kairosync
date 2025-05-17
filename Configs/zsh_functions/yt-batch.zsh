#############################################################
# YouTube Batch Download Function
#############################################################

YT_OPTS=(
    --prefer-free-formats
    --format-sort-force
    --merge-output-format "mkv"
    --concurrent-fragments 3
    --no-mtime
    --output "%(title)s [%(id)s][%(height)sp][%(fps)sfps][%(vcodec)s][%(acodec)s].%(ext)s"
    --external-downloader aria2c
    --external-downloader-args "-x 16 -s 16 -k 1M"
)

function yt-batch() {
    local urls=""
    print -P "%F{blue}Enter video URLs (separated by commas). Press [ENTER] when done:%f"
    vared urls

    if [[ -z "$urls" ]]; then
        print -P "%F{yellow}No URLs entered. Exiting.%f"
        return 0
    fi

    local failed_urls=()
    local IFS=','
    for url_item in ${=urls}; do
        if [[ -z "$url_item" ]]; then
            continue
        fi
        print -P "\n%F{yellow}Downloading: $url_item%f"
        if ! ytmax "$url_item"; then
            failed_urls+=("$url_item")
            print -P "%F{red}Failed to download: $url_item%f"
        fi
    done

    if (( ${#failed_urls[@]} > 0 )); then
        print -P "\n%F{red}Failed URLs:%f"
        printf '%s\n' "${failed_urls[@]}"
    fi
}
