#!/usr/bin/env bash
cd `dirname $0`/..

rm -r klog-win32-x64

konrad

node_modules/.bin/electron-rebuild

IGNORE="/(.*\.dmg$|Icon$|watch$|coffee$|icons$|.*md$|pug$|styl$|.*\.noon$|.*\.lock$|img/banner\.png)"

node_modules/electron-packager/cli.js . --overwrite --icon=img/app.ico --ignore=$IGNORE--win32metadata.FileDescription=klog

mkdir klog-win32-x64/resources/app/coffee
cp -f ./coffee/menu.noon klog-win32-x64/resources/app/coffee
