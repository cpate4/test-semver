#!/usr/bin/env bash
#
# this script is responsible for downloading all dependencies as wheels
# to support building a databricks asset bundle archive via GitHub Action (GHA).
#
# usage (and to test locally):
# ./scripts/download.sh
#

# script variables and defaults
ROOT_DIR=$(dirname $(dirname $(realpath $0)))
TEMP_DIR="${ROOT_DIR}/tmp"
mkdir -p $TEMP_DIR

source $ROOT_DIR/scripts/lib.sh

fail() {
  echo "Missing one of the required ENV variables."
  # echo "DATABRICKS_HOST:       '${DATABRICKS_HOST}'"       # e.g. https://adb-110501499366923.3.azuredatabricks.net
  # echo "DATABRICKS_BUNDLE_DIR: '${DATABRICKS_BUNDLE_DIR}'" # e.g. DAB root-directory
  # echo "DATABRICKS_BUNDLE_ENV: '${DATABRICKS_BUNDLE_ENV}'" # e.g. `target` specified in `databricks.yml`
  exit 1
}
[[ -z $ROOT_DIR ]] && fail

DIST_DIR=${DIST_DIR:-"${TEMP_DIR}/dist"}

cd $ROOT_DIR
poetry build --format wheel --output $DIST_DIR
poetry export -f requirements.txt --output $DIST_DIR/requirements.txt
poetry run pip download -r $DIST_DIR/requirements.txt -d $DIST_DIR/wheels
