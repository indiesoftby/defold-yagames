#!/bin/bash

# Requirements: awk, curl, java, jq, perl, wget, zip

# Immediately exit if any command has a non-zero exit status:
set -e

# This demo doesn't implement Service Worker and Native Cache, so remove them from the settings:
sed -i 's/service_worker_url = .*//' game.project
sed -i 's/manifest_url = .*//' game.project

mkdir -p build

BOB_SHA1=$(curl -s 'https://d.defold.com/stable/info.json' | jq -r .sha1)
BOB_LOCAL_SHA1=$((java -jar build/bob.jar --version | cut -d' ' -f6) || true)
if [ "${BOB_LOCAL_SHA1}" != "${BOB_SHA1}" ]; then wget --progress=dot:mega -O build/bob.jar "https://d.defold.com/archive/${BOB_SHA1}/bob/bob.jar"; fi
TITLE=$(awk -F "=" '/^title/ {gsub(/[ \r\n\t]/, "", $2); print $2}' game.project)
SETTINGS="--build-server https://build.defold.com --variant debug --email foo@bar.com --auth 12345 --texture-compression true"
PLATFORM=js-web
java -jar build/bob.jar ${SETTINGS} --bundle-output build/bundle/${PLATFORM} --platform ${PLATFORM} --architectures wasm-web --archive resolve build bundle
perl -pi -e "s/cachePrefix \+ \"-v1\"/cachePrefix + \"-v$(date +%s)\"/g" "build/bundle/${PLATFORM}/${TITLE}/sw.js"
(cd "build/bundle/${PLATFORM}/${TITLE}" && rm -f "../../bundle_${PLATFORM}.zip" && zip -r "../../bundle_${PLATFORM}.zip" .)
