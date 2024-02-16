#!/bin/bash
set -e
shopt -s nullglob

export SHELL=$(type -p bash)

all_globs_match_at_least_one_file() {
  lines=()
  while read p; do
    if [[ "$p" =~ ^# ]]; then
      :
    elif [[ "$p" =~ ^\s*$ ]]; then
      :
    else
      gb=$(echo "$p" | cut -d' ' -f1)
      lines+=("$gb")
    fi
  done <.github/CODEOWNERS

  export OUTPUT_FILE=$(mktemp)
  echo "Writing to tmp file: $OUTPUT_FILE"

  glob_matches_existing_file() {
    gb="$1" # line in codeowners

    if [[ "$gb" =~ ^\/ ]]; then
      gb="${gb:1}"
    fi

    if [[ "$gb" =~ ^\* ]]; then
      gb="./${gb}"
    fi

    # ugly but works to bridge gap between sys glob & GH codeowner glob
    m1=$(compgen -G "${gb}" | wc -l)
    m2=$(compgen -G "${gb}*" | wc -l)
    m3=$(compgen -G "${gb}/*" | wc -l)
    m4=$(compgen -G "${gb}**/*" | wc -l)

    if [ "$m1" -eq "0" ] && [ "$m2" -eq "0" ] && [ "$m3" -eq "0" ] && [ "$m4" -eq "0" ]; then
      echo "$gb ($m1 $m2 $m3 $m4)" >>$OUTPUT_FILE
    else
      echo -n '.'
    fi
  }

  export -f glob_matches_existing_file
  parallel glob_matches_existing_file ::: ${lines[@]}

  echo ""

  nomatches=$(cat $OUTPUT_FILE | wc -l)

  if [ "$nomatches" -ne "0" ]; then
    echo "No matches found for the following files:"
    cat $OUTPUT_FILE
    exit 1
  else
    echo "All good"
  fi
}

all_globs_match_at_least_one_file
