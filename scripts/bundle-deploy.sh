#!/usr/bin/env bash
#
# this script is run by the build-and-test.yml GitHub Action (GHA).
#
# its purpose is to validate, build, and verify the deployment
# of a databricks asset bundle (DAB).
#
# usage (and to test locally):
# ./scripts/build_and_deploy.sh [databricks.yml:target] [options]
#
ROOT_DIR=$(dirname $(dirname $(realpath $0)))
source $ROOT_DIR/scripts/init.sh

DATABRICKS_BUNDLE_ENV=${1:-$DATABRICKS_BUNDLE_ENV}
shift

fail() {
  echo "Missing one of the required ENV variables."
  echo "DATABRICKS_HOST:       '${DATABRICKS_HOST}'"       # e.g. https://adb-110501499366923.3.azuredatabricks.net
  echo "DATABRICKS_BUNDLE_DIR: '${DATABRICKS_BUNDLE_DIR}'" # e.g. DAB root-directory
  echo "DATABRICKS_BUNDLE_ENV: '${DATABRICKS_BUNDLE_ENV}'" # e.g. target specified in `databricks.yml`
  exit 1
}
[[ -z $DATABRICKS_HOST || -z $DATABRICKS_BUNDLE_DIR || -z $DATABRICKS_BUNDLE_ENV ]] && fail

cd "$DATABRICKS_BUNDLE_DIR"
DATABRICKS_BUNDLE_ENV="${DATABRICKS_BUNDLE_ENV}" databricks bundle deploy "$@"
