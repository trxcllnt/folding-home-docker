#! /usr/bin/env bash

set -e

cd $(dirname $(realpath "$0"))

if [ ! -f "$PWD/config.xml" ]; then
    bash -i ./configure.sh
fi

NVIDIA_VISIBLE_DEVICES=all \
exec docker run --rm \
  -e PUID=$(id -u) \
  -e PGID=$(id -g) \
  -e NVIDIA_VISIBLE_DEVICES=all \
  -e TZ=US/West \
  -e FILE__PASSWORD=/config/.fah-password \
  -p 7396:7396 \
  -v "$PWD":/config \
  ${@:1} \
  linuxserver/foldingathome:latest
