#!/bin/bash
ng build -prod --base-href=/hanisaf/
scp -r dist/* people.terry.uga.edu:~/public_html
