#!/bin/sh

echo "build-swu.sh beg"

BOARD_DIR="$(dirname $0)"
make -C ${BOARD_DIR}/swu IMG="$1" all

echo "build-swu.sh end"
