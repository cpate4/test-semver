#!/usr/bin/env bash
#
# WARNING:
# It is imperative that we limit the output of this shell script to
# what is echo'd at the end of the file.
#
# This file is used in GHA to ferret out if any databricks asset bundles
# have been modified as a part of the changes being proposed.
# Adding additional output will cause the GHA to fail
#
# usage (and to test locally):
# ./scripts/find_bundles.sh "$(git diff --name-only 340b6c8..013bbfb)"
#
ALL_FILES=$1
ALL_FILES=(${ALL_FILES//$'\n'/ })

ROOT_DIRS=()

for FILE in ${ALL_FILES[@]}; do
  PARENT_DIR=$(dirname $FILE)

  while [ "$PARENT_DIR" != "." ]; do
    if [[ -f "./${PARENT_DIR}/databricks.yml" && ! ${ROOT_DIRS[@]} =~ $PARENT_DIR ]]; then
      ROOT_DIRS+=("${PARENT_DIR}")
      break
    else
      PARENT_DIR="$(dirname $PARENT_DIR)"
    fi
  done

done

DATA=$(echo "$(jq -c -n '$ARGS.positional' --args "${ROOT_DIRS[@]}")")
echo $DATA
