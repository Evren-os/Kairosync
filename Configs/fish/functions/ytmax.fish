function ytmax --description "Downloads YouTube videos with yt-dlp, specific resolution/codec"
    # YT_OPTS is expected to be a global list variable (set in config.fish)

    set -l options \
        (fish_opt --short m --long max-res --description "Maximum resolution (default 2160p)" --takes-value) \
        (fish_opt --short C --long codec --description "Codec preference: 'av1' or 'vp9' (default av1)" --takes-value) \
        (fish_opt --short h --long help --description "Show this help message")

    argparse $options -- $argv
    if set -q _flag_help
        echo "Usage: ytmax [OPTIONS] <URL>"
        echo $options # This prints the defined options help
        echo -e "\nShared yt-dlp options (YT_OPTS) are set globally:\n  $YT_OPTS"
        return 0
    end

    if test (count $argv) -eq 0
        echo (set_color red)"Error: URL is required."(set_color normal) >&2
        echo "Usage: ytmax [OPTIONS] <URL>"
        echo "Use 'ytmax --help' for more information."
        return 1
    end
    set -l url $argv[1]

    set -l max_res "$_flag_max_res"
    set -l codec_pref (string lower -- "$_flag_codec") # Convert to lowercase

    # Set defaults if options not provided
    if test -z "$max_res"; set max_res 2160; end
    if test -z "$codec_pref"; set codec_pref "av1"; end

    if not string match -q -r -- '^[0-9]+$' "$max_res"
        echo (set_color red)"Error: --max-res must be a number (e.g., 1080, 2160)."(set_color normal) >&2
        return 1
    end

    set -l format_string "bv*[height<=$max_res][vcodec~='^((av01|vp9|h265|h264).*)$']" # Video: AV1, VP9, HEVC, H264
    set -a format_string "+ba[acodec~='^(opus|aac|vorbis|mp3)$']" # Audio: Opus, AAC, Vorbis, MP3
    set -a format_string "/bv*[height<=$max_res]+ba" # Fallback for merged formats
    set -a format_string "/b*[height<=$max_res]" # Fallback for any single file up to res

    set -l sort_string "res,fps" # Base sort
    switch "$codec_pref"
        case "av1"
            set sort_string "$sort_string,vcodec:av01,vcodec:vp9.2,vcodec:vp9,vcodec:hev1,acodec:opus"
        case "vp9"
            set sort_string "$sort_string,vcodec:vp9.2,vcodec:vp9,vcodec:av01,vcodec:hev1,acodec:opus"
        case "*"
            echo (set_color red)"Invalid codec preference: '$codec_pref'. Use 'av1' or 'vp9'."(set_color normal) >&2
            return 1
    end

    if not set -q YT_OPTS
        echo (set_color yellow)"Warning: Global YT_OPTS variable not set. Using minimal defaults."(set_color normal) >&2
        # Define a minimal YT_OPTS if not found, though it should be in config.fish
        set -l YT_OPTS --merge-output-format "mkv"
    end

    echo "Attempting to download '$url' with max_res=${max_res}p, codec_pref=$codec_pref"
    yt-dlp $YT_OPTS --format "$format_string" --format-sort "$sort_string" "$url"
end
