#!/usr/bin/env bash
#
# this script is run by the build-and-test.yml GitHub Action (GHA).
#
# its purpose is to validate and deploy the specified
# databricks asset bundle (DAB) archive.
#
# usage (and to test locally):
# ./scripts/bundle-deploy.sh [path/to/bundle-dir] [databricks.yml:target] [options]
#
ROOT_DIR=$(dirname $(dirname $(realpath $0)))
source $ROOT_DIR/scripts/init.sh

DATABRICKS_BUNDLE_DIR=${1:-$DATABRICKS_BUNDLE_DIR}
shift

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

cd "${DATABRICKS_BUNDLE_DIR}"
# look for asset bundle package in build dir
DATABRICKS_BUNDLE_ID=${DATABRICKS_BUNDLE_ID:-$(yq .bundle.name databricks.yml | tr '[:upper:]' '[:lower:]' | tr ' ' '_')}
DATABRICKS_BUNDLE_TAG=${DATABRICKS_BUNDLE_TAG:-$(git rev-parse --short HEAD)}

log_info "deploying databricks asset bundle: ${DATABRICKS_BUNDLE_ID}"
log_debug "${DATABRICKS_BUNDLE_ID} tag: ${DATABRICKS_BUNDLE_TAG}"

array=($DATABRICKS_BUNDLE_ID $DATABRICKS_BUNDLE_TAG)
string="${array[*]}" # creates a space-delimited string
string="${string// /-}"

echo ""
cd - >/dev/null
# evaluate if the bundle exists (turn ls results into array)
DATABRICKS_BUNDLE_ARCHIVE=($(ls $BUILD_DIR/$DATABRICKS_BUNDLE_ID-*.tgz))

log_info "Found the following DAB-archives:"
echo "$(printf '%s\n' "${DATABRICKS_BUNDLE_ARCHIVE[@]}")"
echo ""
[ ${#DATABRICKS_BUNDLE_ARCHIVE[@]} -ne 1 ] && log_err "Please make sure there is only one available (see: ./scripts/bundle-package.sh)." && exit 1

WORKING_DIR="${TEMP_DIR}"/${DATABRICKS_BUNDLE_ID}
mkdir -p $WORKING_DIR

tar xvf "${DATABRICKS_BUNDLE_ARCHIVE[@]}" --directory "${WORKING_DIR}"
cd "${WORKING_DIR}"
DATABRICKS_BUNDLE_ENV="${DATABRICKS_BUNDLE_ENV}" databricks bundle deploy "$@"
