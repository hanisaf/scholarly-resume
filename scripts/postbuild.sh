#!/bin/bash
# Post-build script to copy index.csr.html to index.html for GitHub Pages
cp dist/scholarly-resume/browser/index.csr.html dist/scholarly-resume/browser/index.html
echo "Copied index.csr.html to index.html"
