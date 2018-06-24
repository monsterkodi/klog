#!/usr/bin/env bash
cd `dirname $0`/..

if rm -rf klog-win32-x64; then
    
    konrad

    node_modules/.bin/electron-rebuild

    node_modules/electron-packager/cli.js . --overwrite --icon=img/app.ico
    
    rm -rf klog-win32-x64/resources/app/inno

fi