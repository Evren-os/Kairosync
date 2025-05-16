function yt-batch --description "Batch downloads YouTube videos using ytmax"
    if not functions -q ytmax
        echo (set_color red)"Error: 'ytmax' function not found."(set_color normal) >&2
        return 1
    end

    # Could add argparse here to pass --max-res or --codec to all ytmax calls
    # For now, it uses ytmax defaults or ytmax's own argument parsing if called directly.

    read -P (printf "%sEnter video URLs (space separated, use quotes for URLs with spaces):%s " (set_color blue) (set_color normal)) -a urls
    if count $urls -eq 0
        echo (set_color yellow)"No URLs entered. Exiting."(set_color normal)
        return 0
    end

    set -l failed_urls
    for url_item in $urls
        set url_item (string trim $url_item) # Trim whitespace from each URL
        if test -z "$url_item"; continue; end # Skip empty items

        echo # Add a newline for better readability per download
        echo (set_color yellow)"Processing URL: $url_item"(set_color normal)

        # Call ytmax. It will use its default resolution/codec unless this function is enhanced
        # to pass arguments through.
        if not ytmax "$url_item"
            set -a failed_urls "$url_item"
            echo (set_color red)"Failed to download (or ytmax reported an error for): $url_item"(set_color normal)
        end
    end

    if count $failed_urls -gt 0
        echo # Newline
        echo (set_color red)"--- Batch Download Summary: Some URLs failed ---"(set_color normal)
        echo (set_color red)"Failed URLs:"(set_color normal)
        for failed_url in $failed_urls
            echo "  ✗ $failed_url"
        end
        return 1 # Indicate some failures
    else
        echo # Newline
        echo (set_color green)"--- Batch Download Summary: All URLs processed. ---"(set_color normal)
        echo (set_color green)"(Check ytmax output for individual success/failure details)"(set_color normal)
        return 0
    end
end
