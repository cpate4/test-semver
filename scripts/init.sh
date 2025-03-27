#!/usr/bin/env bash


BUILD_DIR=${BUILD_DIR:-"$ROOT_DIR/build"}
mkdir -p "$BUILD_DIR"

SCRIPT_DIR="${ROOT_DIR}/scripts"

TEMP_DIR="${ROOT_DIR}/tmp"
mkdir -p $TEMP_DIR

source ${SCRIPT_DIR}/lib.sh
