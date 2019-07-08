#!/usr/bin/env bash
cd `dirname $0`/..

konrad --run

IGNORE="/(.*\.dmg$|Icon$|watch$|icons$|.*md$|pug$|styl$|.*\.lock$|img/banner\.png)"

node_modules/.bin/electron-packager . --overwrite --icon=img/app.icns --ignore=$IGNORE
