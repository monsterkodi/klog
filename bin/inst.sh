#!/usr/bin/env bash
cd `dirname $0`/..

if rm -rf /Applications/klog.app; then

    cp -R klog-darwin-x64/klog.app /Applications

    open /Applications/klog.app 
fi
