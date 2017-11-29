#!/bin/sh

# This script simplifies working with maven when you want to have separate local maven repositories depending on the directory
# you are working in. To use it, add the following line to your .profile or .bashrc
#
# alias mvn=/path/to/invoke-maven.sh
#
# At paxata we frequently work on multiple release branches simultaneously, and we also use maven SNAPSHOT dependencies 
# extensively. This means that if you switch over to a different release branch and run a "mvn install", then you've 
# just overwritten the snapshot dependencies that are used by another branch. This is the source of a lot of wasted time
# re-running "mvn install" every time you switch between release branches. The workaround I'm using here is to have separate 
# directories for each release branch that I'll be working on. The overall layout looks like so:
#
# projects/
#   |- 2.20/
#   |   |- paxata
#   |   |- pax
#   |   |- m2repository
#   |   \...
#   |
#   |- 2.21/
#   |   |- paxata
#   |   |- pax
#   |   |- m2repository
#   |   \...
#   |...
# 
# Having separate checkouts in this way, along with aliasing mvn to this script, allows for switching between release branches more easily.
# If you happen to be outside of any of these directories, then invoking maven will just work like normal (no arguments will be added).
# Hope it helps


MAVEN_EXECUTABLE="$(which mvn)"
MAVEN_REPO_DIR=m2repository
WORKING_DIR="$(pwd)"

find_maven_repo_dir() {
  local current_dir="$1"
  while [[ ! -d "${current_dir}/${MAVEN_REPO_DIR}" && "${current_dir}" != "/" ]]; do 
    if [ "$current_dir" != "/" ]; then
      current_dir="$(cd "${current_dir}/.." && pwd)"
    fi
  done

  if [ -d "${current_dir}/${MAVEN_REPO_DIR}" ]; then 
    echo "${current_dir}/${MAVEN_REPO_DIR}"
  fi
}


LOCAL_M2_REPO_DIR="$(find_maven_repo_dir "$WORKING_DIR")"

if [[ -z "$LOCAL_M2_REPO_DIR" ]]; then 
  echo "invoking mvn without adding local repository argument"
  "$MAVEN_EXECUTABLE" -Dmaven.repo.local=$LOCAL_M2_REPO_DIR $@
else 
  echo invoking "$MAVEN_EXECUTABLE" -Dmaven.repo.local=$LOCAL_M2_REPO_DIR $@
  "$MAVEN_EXECUTABLE" -Dmaven.repo.local=$LOCAL_M2_REPO_DIR $@
fi


