#!/bin/sh
jazzy --swift-version 2.1 --source-directory framework --author "Adam Michael" --author_url "https://github.com/csse497/pathfinder" --github_url "https://github.com/csse497/pathfinder-ios" --readme README.md -x -workspace framework/Pathfinder.xcworkspace -x -scheme=Pathfinder
