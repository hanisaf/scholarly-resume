#! /bin/bash
# if not installed
#npm install -g angular-cli-ghpages
ng build --configuration production --base-href /scholarly-resume/
npx angular-cli-ghpages --dir=dist/scholarly-resume/browser
