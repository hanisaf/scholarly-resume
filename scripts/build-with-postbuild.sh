#!/bin/bash
# Build script that properly handles arguments and runs postbuild
npx ng build "$@"
BUILD_EXIT=$?

if [ $BUILD_EXIT -eq 0 ]; then
    echo "Build successful, running postbuild script..."
    ./scripts/postbuild.sh
else
    echo "Build failed with exit code $BUILD_EXIT"
    exit $BUILD_EXIT
fi
