#!/bin/sh
set -eu

IMAGE=docker.io/library/ubuntu:24.04
ROOT=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)

usage() {
    echo "Usage: $0 [-i ubuntu-image]"
}

while getopts "i:h" opt; do
    case "$opt" in
        i) IMAGE=$OPTARG ;;
        h) usage; exit 0 ;;
        *) usage >&2; exit 1 ;;
    esac
done
shift "$((OPTIND - 1))"
if [ "$#" -ne 0 ]; then
    usage >&2
    exit 1
fi

mkdir -p "$ROOT/build" "$ROOT/tarballs"

docker build --build-arg "BASE_IMAGE=$IMAGE" --tag diff-so-fancy-source-builder "$ROOT"
docker run --rm \
    --mount "type=bind,source=$ROOT/debian,target=/packaging,readonly" \
    --mount "type=bind,source=$ROOT/tarballs,target=/tarballs" \
    --mount "type=bind,source=$ROOT/build,target=/output" \
    diff-so-fancy-source-builder
