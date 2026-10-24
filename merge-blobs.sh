#!/bin/bash
# Reassemble split >100MB blobs ignored by git (see .gitignore).
# Auto-invoked from shiba-vendor.mk at build parse time; safe to run by hand too.
# APK/apex parts are merged by Soong genrules at build time (hash-checked there too).
set -e
cd "$(dirname "$0")"
MODEM_SHA256="9dbad6dccd0ad81778c7b54d377cf3268e26b7576b51c86f25c69ed815a869e2"
for p in proprietary/product/priv-app/GoogleCamera/GoogleCamera.apk.part_* \
         proprietary/product/priv-app/DevicePersonalizationAiAiPrebuiltPixel2023/DevicePersonalizationAiAiPrebuiltPixel2023.apk.part_* \
         proprietary/product/priv-app/PixelCameraServices/PixelCameraServices.apk.part_* \
         proprietary/vendor/apex/com.google.pixel.camera.hal.apex.part_* \
         radio/modem.img.part_*; do
    [ -e "$p" ] || { echo "merge-blobs: MISSING parts: $p" >&2; exit 1; }
done
if echo "$MODEM_SHA256  radio/modem.img" | sha256sum -c - >/dev/null 2>&1; then
    echo "merge-blobs: modem.img already OK, skip"
else
    cat radio/modem.img.part_* > radio/modem.img
    echo "$MODEM_SHA256  radio/modem.img" | sha256sum -c -
    echo "merge-blobs: modem.img restored OK"
fi
