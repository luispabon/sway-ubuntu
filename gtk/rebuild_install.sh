#!/bin/bash

# Install sources and build deps
apt-get source "gtk+3.0"
sudo apt-get build-dep "gtk+3.0"

# Figure out sources folder
sources_dir=`find . -name "*.dsc" | sed -E 's/.\///' | sed -E 's/-[0-9]ubuntu[0-9].dsc//' | sed -E 's/_/-/'`

echo "### GTK version: '${sources_dir}'"

# Apply patches
cd "${sources_dir}"

echo "### Patching in Firefox fixes..."
patch -p1 < ../3941.diff
patch -p1 < ../3944.diff

echo "### Done"

# Build deb packages
dpkg-buildpackage -rfakeroot -b -us -uc

# Cleanup build artifacts we don't need, like debug symbols
cd ..
rm *.ddeb

# Install deb files
sudo dpkg -i *.deb
