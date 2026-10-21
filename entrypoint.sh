#!/bin/sh
set -eu

SOURCE=$(dpkg-parsechangelog --file /packaging/changelog --show-field Source)
VERSION=$(dpkg-parsechangelog --file /packaging/changelog --show-field Version)
UPSTREAM_VERSION=${VERSION#*:}
UPSTREAM_VERSION=${UPSTREAM_VERSION%-*}
ARCHIVE="${SOURCE}_${UPSTREAM_VERSION}.orig.tar.gz"

WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT
trap 'exit 1' HUP INT TERM

if [ ! -f "/tarballs/$ARCHIVE" ]; then
    curl --fail --location --retry 3 \
        --output "$WORK/$ARCHIVE" \
        "https://github.com/so-fancy/diff-so-fancy/archive/refs/tags/v${UPSTREAM_VERSION}.tar.gz"
    install -m 644 \
        -o "$(stat -c %u /tarballs)" -g "$(stat -c %g /tarballs)" \
        "$WORK/$ARCHIVE" "/tarballs/$ARCHIVE"
fi

cp "/tarballs/$ARCHIVE" "$WORK/$ARCHIVE"
mkdir "$WORK/source"
tar -xzf "$WORK/$ARCHIVE" --strip-components=1 -C "$WORK/source"
cp -a /packaging "$WORK/source/debian"
cd "$WORK/source"

dpkg-buildpackage -S -sa -us -uc

# Exclude .buildinfo from the PPA upload manifest.
dpkg-genchanges -S -sa -f/dev/null > "$WORK/${SOURCE}_${VERSION#*:}_source.changes"

for artifact in "$WORK"/*.dsc "$WORK"/*.debian.tar.* \
    "$WORK"/*.orig.tar.gz "$WORK"/*_source.changes; do
    install -m 644 \
        -o "$(stat -c %u /output)" -g "$(stat -c %g /output)" \
        "$artifact" /output/
done

printf '\nUnsigned source package: build/%s_%s_source.changes\n' "$SOURCE" "${VERSION#*:}"
