#!/usr/bin/env bash

DIR=`dirname $0`
BIN=$DIR/../node_modules/.bin
cd $DIR/..

if rm -rf klog-darwin-x64; then

    if $BIN/konrad; then
    
        IGNORE="/(.*\.dmg$|Icon$|watch$|icons$|.*md$|pug$|styl$|.*\.lock$|img/banner\.png)"
        
        if $BIN/electron-packager . --overwrite --icon=img/app.icns --darwinDarkModeSupport --ignore=$IGNORE; then
        
            rm -rf /Applications/klog.app
            cp -R klog-darwin-x64/klog.app /Applications
            
            open /Applications/klog.app 
        fi
    fi
fi
