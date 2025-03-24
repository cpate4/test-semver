#!/usr/bin/env bash

# Importing these functions into your script should be done by including this line
# at the top of your script
#
# source RELATIVE/PATH/TO/lib.sh
#
# where relative path is the path to this file relative to the directory the script is intended to be invoked from
# absolute paths should work fine too.

# Basic logging lib
# Usage: log_info "my message"
# Output: 2024-11-22 12:44:46 [INFO] my message

# ERROR = 0
# INFO = 1
# DEBUG = 2
declare -i desired_log_level=2

log_debug() { _log_execute 'DEBUG' "$1"; }
log_info() { _log_execute 'INFO' "$1"; }
log_err() { _log_execute 'ERROR' "$1"; }

_log_execute() {
  local -r log_message=$2
  local -r log_level=$1

  case "$log_level" in
  ERROR) priority=0 ;;
  INFO) priority=1 ;;
  DEBUG) priority=2 ;;
  *) return 1 ;;
  esac

  # check if level is at least desired level
  [[ ${priority} -le ${desired_log_level} ]] && _log_msg "$log_message" "$log_level"

  # don't want to exit with error code on messages of lower priority
  return 0
}

_log_msg() {
  local -r timestamp=$(date "+%Y-%m-%d %H:%M:%S")
  printf '%s [%-5s] %s\n' "$timestamp" "$2" "$1"
}

# Usage:
# required_tools=( tool1 tool2 )
# check_required_tools "${required_tools[@]}" || exit 1;
check_required_tools() {
  tools=("$@")
  for tool in "${tools[@]}"; do
    [[ $(type -P "$tool") ]] || {
      log_err "$tool not found on PATH, please install $tool"
      return 1
    }
    log_debug "found $tool on PATH"
  done
  log_info 'all required tools found on PATH'
}

# Usage: retrieves the latest semver tag if on main branch, otherwise
# returns a branch name + semver tag + short commit SHA
get_git_tag() {
  # if an explicit git tag was passed in via CONFIF_GIT_TAG just use that
  if [ -n "${git_tag}" ]; then
    log_info "git tag explicitly passed in as ${git_tag}"
    return 0
  fi

  log_info "determining git tag"
  git fetch --tags
  # Get the current branch name
  current_branch=$(git rev-parse --abbrev-ref HEAD)

  # Get the latest tag reachable from the current commit
  latest_tag=$(git describe --tags --abbrev=0 2>/dev/null)

  # If no tag found, use a default version
  if [ -z "$latest_tag" ]; then
    latest_tag="0.0.0"
  fi

  # If on main branch, return the latest tag as-is
  if [ "$current_branch" = "main" ]; then
    git_tag="${latest_tag}"
  else
    # Get the short commit SHA
    short_sha=$(git rev-parse --short HEAD)

    # Append the short SHA to the latest tag
    git_tag="${current_branch}-${latest_tag}-${short_sha}"
  fi

  log_info "appconfig snapshot label is ${git_tag}"
}
