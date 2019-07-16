#!/usr/bin/env bash
DIR=`dirname $0`
BIN=$DIR/../node_modules/.bin
cd $DIR/..

if rm -rf klog-win32-x64; then
    
    if $BIN/konrad; then

        $BIN/electron-rebuild
    
        $BIN/electron-packager . --overwrite --icon=img/app.ico
        
        rm -rf klog-win32-x64/resources/app/inno
        
        start klog-win32-x64/klog.exe
    fi
fi