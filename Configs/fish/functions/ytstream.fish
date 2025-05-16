function ytstream --description "Streams YouTube videos with mpv, specific resolution/codec"
    if not command -sq mpv
        echo (set_color red)"Error: mpv command not found. Please install mpv to stream videos."(set_color normal) >&2
        return 1
    end
    if not command -sq yt-dlp
        echo (set_color red)"Error: yt-dlp command not found."(set_color normal) >&2
        return 1
    end

    set -l options \
        (fish_opt --short m --long max-res --description "Maximum resolution (default 2160p)" --takes-value) \
        (fish_opt --short C --long codec --description "Codec preference: 'av1' or 'vp9' (default av1)" --takes-value) \
        (fish_opt --short h --long help --description "Show this help message")

    argparse $options -- $argv
    if set -q _flag_help
        echo "Usage: ytstream [OPTIONS] <URL>"
        echo $options
        return 0
    end

    if test (count $argv) -eq 0
        echo (set_color red)"Error: URL is required."(set_color normal) >&2
        echo "Usage: ytstream [OPTIONS] <URL>"
        echo "Use 'ytstream --help' for more information."
        return 1
    end
    set -l url $argv[1]

    set -l max_res "$_flag_max_res"
    set -l codec_pref (string lower -- "$_flag_codec")

    if test -z "$max_res"; set max_res 2160; end
    if test -z "$codec_pref"; set codec_pref "av1"; end

    if not string match -q -r -- '^[0-9]+$' "$max_res"
        echo (set_color red)"Error: --max-res must be a number (e.g., 1080, 2160)."(set_color normal) >&2
        return 1
    end

    set -l format_string "bv*[height<=$max_res][vcodec~='^((av01|vp9|h265|h264).*)$']"
    set -a format_string "+ba[acodec~='^(opus|aac|vorbis|mp3)$']"
    set -a format_string "/bv*[height<=$max_res]+ba"
    set -a format_string "/b*[height<=$max_res]"


    set -l sort_string "res,fps"
    switch "$codec_pref"
        case "av1"
            set sort_string "$sort_string,vcodec:av01,vcodec:vp9.2,vcodec:vp9,vcodec:hev1,acodec:opus"
        case "vp9"
            set sort_string "$sort_string,vcodec:vp9.2,vcodec:vp9,vcodec:av01,vcodec:hev1,acodec:opus"
        case "*"
            echo (set_color red)"Invalid codec preference: '$codec_pref'. Use 'av1' or 'vp9'."(set_color normal) >&2
            return 1
    end

    # --get-url doesn't use all YT_OPTS, but --prefer-free-formats is good.
    echo "Fetching stream URL for '$url' (max_res=${max_res}p, codec_pref=$codec_pref)..."
    set -l stream_url_output (yt-dlp --prefer-free-formats --format "$format_string" --format-sort "$sort_string" --get-url "$url" 2>/dev/null)
    set -l yt_dlp_status $status

    if test $yt_dlp_status -ne 0; or test -z "$stream_url_output"
        echo (set_color red)"Failed to get stream URL for $url."(set_color normal) >&2
        # Rerun with stderr to show yt-dlp's error
        yt-dlp --prefer-free-formats --format "$format_string" --format-sort "$sort_string" --get-url "$url"
        return 1
    end

    # yt-dlp might output multiple URLs if it finds separate video/audio. Take the first one.
    set -l stream_url (echo $stream_url_output | string split \n --max 1)

    echo (set_color green)"Streaming with mpv..."(set_color normal)
    mpv "$stream_url"
end
