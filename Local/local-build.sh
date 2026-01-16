#!/bin/bash

cd $(dirname $(readlink -f $0))
git clone --recursive https://github.com/Swordfish90/cool-retro-term.git
cp ../Formula/build-macos.sh cool-retro-term/
cd cool-retro-term/
chmod +x build-macos.sh
./build-macos.sh
