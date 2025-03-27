#!/usr/bin/env bash
#
# Creates a DAB-archive, packaging a single databricks asset bundle (DAB)
# while also building all of its consituent artifacts.
#
# usage (and to test locally):
# ./scripts/build-package.sh
#
ROOT_DIR=$(dirname $(dirname $(realpath $0)))
source $ROOT_DIR/scripts/init.sh

fail() {
  echo "Missing one of the required ENV variables."
  echo "DATABRICKS_BUNDLE_DIR: '${DATABRICKS_BUNDLE_DIR}'" # e.g. DAB root-directory
  exit 1
}
[[ -z $DATABRICKS_BUNDLE_DIR ]] && fail

# DATABRICKS_BUNDLE_DIR=$(realpath "$DATABRICKS_BUNDLE_DIR")
cd "${DATABRICKS_BUNDLE_DIR}"

# build the artifacts
ARTIFACTS_DIR="./artifacts"
ARTIFACTS=$(ls $ARTIFACTS_DIR | grep -v notebooks)
if [ -n "${ARTIFACTS[@]}" ]; then
  for artifact in $ARTIFACTS; do
    artifact_dir="$ARTIFACTS_DIR/$artifact"
    [ -f "$artifact_dir/gradlew" ] && ARTIFACT_DIR="$artifact_dir" $SCRIPT_DIR/gradle-build-and-test.sh
    [ -f "$artifact_dir/poetry.lock" ] && ARTIFACT_DIR="$artifact_dir" $SCRIPT_DIR/poetry-build-and-test.sh
    echo ""
  done
fi


DATABRICKS_BUNDLE_ID=${DATABRICKS_BUNDLE_ID:-$(yq .bundle.name databricks.yml)}

DATABRICKS_BUNDLE_TAG=${DATABRICKS_BUNDLE_TAG:-$(git rev-parse --short HEAD)}

log_info "archiving databricks asset bundle: ${DATABRICKS_BUNDLE_ID}"
log_debug "${DATABRICKS_BUNDLE_ID} tag: ${DATABRICKS_BUNDLE_TAG}"

array=($DATABRICKS_BUNDLE_ID $DATABRICKS_BUNDLE_TAG)
string="${array[*]}"         # creates a space-delimited string
string="${string// /-}"

DATABRICKS_BUNDLE_ARCHIVE="${BUILD_DIR}/${string}.tgz"

tar cfz ${DATABRICKS_BUNDLE_ARCHIVE} \
    --exclude=".venv" --exclude=".gradle" --exclude="build" \
    artifacts/notebooks/* \
    databricks.yml \
    resources/*

log_info "${DATABRICKS_BUNDLE_ID} archive'd here: ${DATABRICKS_BUNDLE_ARCHIVE}"
# echo ""
# echo "Archived files: ${BUILD_DIR}/${DATABRICKS_BUNDLE}.tgz"
# echo "$(tar tvf ${BUILD_DIR}/${DATABRICKS_BUNDLE}.tgz)"
