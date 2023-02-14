#!/bin/bash

set -x

export APP_NAME="harbour-saildsb"

for x in 86 108 128 172 512
do
  inkscape --export-type="png" -o icons/${x}x${x}/$APP_NAME\_original.png -w ${x} mediasrc/$APP_NAME.svg
  pngcrush -brute icons/${x}x${x}/$APP_NAME\_original.png icons/${x}x${x}/$APP_NAME.png
done
