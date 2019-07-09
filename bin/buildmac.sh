#!/usr/bin/env bash
DIR=`dirname $0`
BIN=$DIR/../node_modules/.bin
cd $DIR/..

if $BIN/konrad --run; then

    IGNORE="/(.*\.dmg$|Icon$|watch$|icons$|.*md$|pug$|styl$|.*\.lock$|img/banner\.png)"
    
    $BIN/electron-packager . --overwrite --icon=img/app.icns --ignore=$IGNORE
fi