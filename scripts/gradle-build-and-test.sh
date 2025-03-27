#!/usr/bin/env bash
#
# Builds a GRADLE artifact,
# moving all jar resources (inc. transitive dependencies)
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
log_info "BUILDING GRADLE artifact: ${ARTIFACT_DIR}"
./gradlew jar
./gradlew downloadDependencies


# stage them in the DATABRICKS_BUNDLE_DIR
cd -
echo "PWD: $(pwd)"
ARTIFACT_ID=$(basename ${ARTIFACT_DIR})
mkdir -p "resources/artifacts/${ARTIFACT_ID}"
cp -v "${ARTIFACT_DIR}"/**/build/libs/*.jar "resources/artifacts/${ARTIFACT_ID}"
