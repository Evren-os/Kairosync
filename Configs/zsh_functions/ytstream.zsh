#############################################################
# YouTube Streaming Functions
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

# Function to stream videos with mpv, capped at 4K, preferring AV1
function ytstream() {
    local max_res=2160
    local codec_pref="av1"
    local url=""
    while [[ $# -gt 0 ]]; do
        case $1 in
            --max-res)
                max_res=$2
                shift 2
                ;;
            --codec)
                codec_pref=$2
                shift 2
                ;;
            *)
                url=$1
                shift
                ;;
        esac
    done
    if [[ -z "$url" ]]; then
        echo "Usage: ytstream [options] URL"
        echo "Options: --max-res RES (default 2160), --codec CODEC (default av1)"
        return 1
    fi
    local format_string="bv*[height<=${max_res}]+ba/bv*[height<=${max_res}]"
    local sort_string
    if [[ "$codec_pref" == "av1" ]]; then
        sort_string="res,fps,vcodec:av01,vcodec:vp9.2,vcodec:vp9,vcodec:hev1,acodec:opus"
    elif [[ "$codec_pref" == "vp9" ]]; then
        sort_string="res,fps,vcodec:vp9,vcodec:vp9.2,vcodec:av01,vcodec:hev1,acodec:opus"
    else
        echo "Invalid codec preference: $codec_pref. Use av1 or vp9."
        return 1
    fi
    local stream_url=$(yt-dlp --prefer-free-formats --format "$format_string" --format-sort "$sort_string" --get-url "$url")
    if [[ -z "$stream_url" ]]; then
        echo "Failed to get stream URL"
        return 1
    fi
    mpv "$stream_url"
}
