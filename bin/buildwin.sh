#!/usr/bin/env bash
DIR=`dirname $0`
BIN=$DIR/../node_modules/.bin
cd $DIR/..

if rm -rf klog-win32-x64; then
    
    $BIN/konrad

    $BIN/electron-rebuild

    node_modules/electron-packager/cli.js . --overwrite --icon=img/app.ico
    
    rm -rf klog-win32-x64/resources/app/inno

fi