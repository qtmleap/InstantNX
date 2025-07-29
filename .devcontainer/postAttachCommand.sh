#!/bin/zsh

find "/home/vscode/app" -type d | while read -r TARGET_DIR; do
  git config --global --add safe.directory "$TARGET_DIR"
done
git config --global --add safe.directory /home/vscode/app
git config --global --unset commit.template
git config --global fetch.prune true
git config --global --add --bool push.autoSetupRemote true
git config --global commit.gpgSign true
git branch --merged|egrep -v '\*|develop|main|master'|xargs git branch -d
