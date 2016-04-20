#!/bin/sh
pushd framework
jazzy \
  --swift-version 2.2 \
  --author "Adam Michael" \
  --author_url "https://thepathfinder.xyz" \
  --github_url "https://github.com/csse497/pathfinder-ios" \
  --output ../docs \
  --readme ../README.md \
  -x -workspace Pathfinder.xcworkspace \
  -x -scheme=Pathfinder
popd
