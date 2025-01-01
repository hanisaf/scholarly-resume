#! /bin/bash
# if not installed
#npm install -g angular-cli-ghpages
export NODE_OPTIONS=--openssl-legacy-provider
ng build --prod --base-href /scholarly-resume/
ngh
