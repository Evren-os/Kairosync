#############################################################
# YouTube Batch Download Function
#############################################################

# Common options for yt-dlp downloads
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

# Function to download multiple videos
function yt-batch() {
    print -P "%F{blue}Enter video URLs (separated by commas). Press [ENTER] when done:%f"
    read -r urls
    local failed_urls=()
    local IFS=','
    for url in ${=urls}; do
        url=${url## }
        url=${url%% }
        print -P "\n%F{yellow}Downloading: $url%f"
        if ! ytmax "$url"; then
            failed_urls+=("$url")
            print -P "%F{red}Failed to download: $url%f"
        fi
    done
    if (( ${#failed_urls[@]} > 0 )); then
        print -P "\n%F{red}Failed URLs:%f"
        printf '%s\n' "${failed_urls[@]}"
    fi
}
