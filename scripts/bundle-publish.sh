#!/usr/bin/env bash
#
# this script is run by the build-and-test.yml GitHub Action (GHA).
#
# its purpose is to PUBLISH the archive associated with the specified
# databricks asset bundle (DAB) directory.
#
# for more information on building archives, please see `bundle-package.sh`
#
# usage (and to test locally):
# ./scripts/bundle-publish.sh [path/to/bundle-dir] [options]
#
ROOT_DIR=$(dirname $(dirname $(realpath $0)))
source $ROOT_DIR/scripts/init.sh

DATABRICKS_BUNDLE_DIR=${1:-$DATABRICKS_BUNDLE_DIR}
shift

fail() {
  echo "Missing one of the required ENV variables."
  echo "DATABRICKS_BUNDLE_DIR: '${DATABRICKS_BUNDLE_DIR}'" # e.g. DAB root-directory
  exit 1
}
[[ -z $DATABRICKS_BUNDLE_DIR ]] && fail

cd "${DATABRICKS_BUNDLE_DIR}"
# look for asset bundle package in build dir
DATABRICKS_BUNDLE_ID=${DATABRICKS_BUNDLE_ID:-$(yq .bundle.name databricks.yml | tr '[:upper:]' '[:lower:]' | tr ' ' '_')}
DATABRICKS_BUNDLE_TAG=${DATABRICKS_BUNDLE_TAG:-$(git rev-parse --short HEAD)}

log_info "PUBLISHING databricks asset bundle: ${DATABRICKS_BUNDLE_ID}"
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

if [ ${#DATABRICKS_BUNDLE_ARCHIVE[@]} -ne 1 ]; then
  log_err "Please make sure there is only one available (see: ./scripts/bundle-package.sh)."
  exit 1
fi



echo $(basename "${DATABRICKS_BUNDLE_ARCHIVE[@]}")
az account show

# WORKING_DIR="${TEMP_DIR}"/${DATABRICKS_BUNDLE_ID}
# mkdir -p $WORKING_DIR

# tar xvf "${DATABRICKS_BUNDLE_ARCHIVE[@]}" --directory "${WORKING_DIR}"
# cd "${WORKING_DIR}"
# DATABRICKS_BUNDLE_ENV="${DATABRICKS_BUNDLE_ENV}" databricks bundle deploy "$@"


echo "PUBLISHING ${DATABRICKS_BUNDLE_TAG} from: '$(pwd)'"
echo $(git rev-parse --short HEAD)

az account
# echo $(which jq)
# echo $(yq '.bundle.name' databricks.yml)
