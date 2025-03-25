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
  echo "DATABRICKS_BUNDLE_DIR: '${DATABRICKS_BUNDLE_DIR}'" # e.g. DAB root-directory
  exit 1
}
[[ -z $DATABRICKS_BUNDLE_DIR ]] && fail

DATABRICKS_BUNDLE=$(basename "$DATABRICKS_BUNDLE_DIR")

BUILD_DIR=${BUILD_DIR:-$TEMP_DIR/dist}
mkdir -p "$BUILD_DIR"

BUNDLE_DIR="${ROOT_DIR}/${DATABRICKS_BUNDLE_DIR}"
cd "$BUNDLE_DIR"

echo "PUBLISHING ${DATABRICKS_BUNDLE_TAG} from: '$(pwd)'"
echo $(git rev-parse --short HEAD)

echo $(which jq)
echo $(which yq)
