#!/usr/bin/env bash

set -e

echo Copying archive to the server...
scp ~/Repositories/rust-learnings/dist/webHelpRL2-all.zip 192.168.1.2:/srv/http/rust
echo copied!

echo Extracting archive in the server...
ssh 192.168.1.2 'cd /srv/http/rust/ ; yes A | unzip webHelpRL2-all.zip ; cd'
echo extracted!
