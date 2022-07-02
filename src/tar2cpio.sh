#!/bin/sh
set -e

if [ $# -ne 2 ]
then
  echo "Convert a TAR rootfs archive to an initrd CPIO archive"
  echo "usage: tar2cpio input.tar output.cpio.gz"
  exit 1
fi

tmpdir="$(mktemp -d -t tar2cpio-XXXXXXXXXX)"
trap 'rm -rf "$tmpdir"' EXIT

tar -C "$tmpdir" -xf "$1"
(
  cd "$tmpdir";
  find . | cpio -o -R root:root -H newc
) | gzip > "$2"

echo "Successfully converted TAR '$1' to CPIO '$2'"