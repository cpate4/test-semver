#!/usr/bin/env bash
#
# Builds a POETRY artifact,
# moving all python resources (inc. transitive dependencies)
# into an appropriately named directory under `resources/artifacts/`
#
ROOT_DIR=$(dirname $(dirname $(realpath $0)))
source $ROOT_DIR/scripts/init.sh

fail() {
  echo "Missing one of the required ENV variables."
  echo "ARTIFACT_DIR: '${ARTIFACT_DIR}'" # e.g. gradle-based artifact directory
  exit 1
}
[[ -z ${ARTIFACT_DIR} ]] && fail

# build and download the artifacts
cd "$ARTIFACT_DIR"
log_info "BUILDING POETRY artifact: ${ARTIFACT_DIR}"
poetry build -f wheel --output dist
poetry export -f requirements.txt --output dist/requirements.txt
poetry run pip download -r dist/requirements.txt -d dist/wheels

# stage them in the DATABRICKS_BUNDLE_DIR
cd -
ARTIFACT_ID=$(basename ${ARTIFACT_DIR})
RESOURCE_DIR="resources/artifacts/${ARTIFACT_ID}"
mkdir -p $RESOURCE_DIR
cp -rv "${ARTIFACT_DIR}/dist"/* "resources/artifacts/${ARTIFACT_ID}"

