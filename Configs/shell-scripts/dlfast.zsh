#############################################################
# aria2 Download Functions
#############################################################

dlfast() {
  if [[ -z "$1" ]]; then
    echo "Usage: dlfast <URL> [FULL_OUTPUT_FILE_PATH_OR_DIR]"
    echo "IMPORTANT: For reliable resume with a new URL, specify the FULL_OUTPUT_FILE_PATH."
    echo "Example (initial): dlfast \"old_url\" \"\$HOME/Downloads/myfile.zip\""
    echo "Example (resume):  dlfast \"new_url\" \"\$HOME/Downloads/myfile.zip\""
    return 1
  fi

  local url="$1"
  local output_target="$2"
  local aria2_opts=()

  if [[ -n "$output_target" ]]; then
    if [[ "${output_target: -1}" == "/" ]]; then
      echo "Warning: Outputting to a directory. Filename will be inferred from URL."
      echo "For best resume reliability with new links, specify the full output file path next time."
      mkdir -p "$output_target"
      aria2_opts+=( "--dir=$output_target" )
    else
      mkdir -p "$(dirname "$output_target")"
      aria2_opts+=( "--out=$output_target" )
    fi
  else
    echo "Warning: No output path specified. Downloading to current directory."
    echo "Filename will be inferred from URL. For best resume, specify full output file path."
  fi

  aria2c \
    --continue=true \
    --max-connection-per-server=16 \
    --split=16 \
    --min-split-size=1M \
    --file-allocation=falloc \
    --max-tries=0 \
    --retry-wait=5 \
    --timeout=60 \
    --max-file-not-found=5 \
    --summary-interval=1 \
    --console-log-level=warn \
    --auto-file-renaming=false \
    --conditional-get=true \
    --check-integrity=true \
    --disk-cache=64M \
    --piece-length=1M \
    --allow-overwrite=true \
    --async-dns=true \
    --http-accept-gzip=true \
    "${aria2_opts[@]}" \
    "$url"
}
