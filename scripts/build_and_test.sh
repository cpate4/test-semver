#!/usr/bin/env bash
#
# this script is run by the build-and-test.yml GitHub Action (GHA).
#
# its purpose is to validate, build, and verify the deployment
# of a databricks asset bundle (DAB).
#
# usage (and to test locally):
# ./scripts/build_and_deploy.sh [asset-bundle-dir]
#

# script variables and defaults
ROOT_DIR=$(dirname $(dirname $(realpath $0)))
TEMP_DIR="${ROOT_DIR}/tmp"
mkdir -p $TEMP_DIR

source $ROOT_DIR/scripts/lib.sh

DATABRICKS_BUNDLE_ENV=${1:-$DATABRICKS_BUNDLE_ENV}
shift

fail() {
  echo "Missing one of the required ENV variables."
  echo "DATABRICKS_HOST:       '${DATABRICKS_HOST}'"       # e.g. https://adb-110501499366923.3.azuredatabricks.net
  echo "DATABRICKS_BUNDLE_DIR: '${DATABRICKS_BUNDLE_DIR}'" # e.g. DAB root-directory
  echo "DATABRICKS_BUNDLE_ENV: '${DATABRICKS_BUNDLE_ENV}'" # e.g. target specified in `databricks.yml`
  exit 1
}
[[ -z $DATABRICKS_HOST || -z $DATABRICKS_BUNDLE || -z $DATABRICKS_BUNDLE_ENV ]] && fail

BUNDLE_DIR="${ROOT_DIR}/${DATABRICKS_BUNDLE}"
BUILD_DIR=${BUILD_DIR:-$TEMP_DIR/dist}
mkdir -p "$BUILD_DIR"

cd "$BUNDLE_DIR"
databricks bundle deploy "$@"
