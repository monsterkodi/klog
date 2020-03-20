###
00     00   0000000   000  000   000
000   000  000   000  000  0000  000
000000000  000000000  000  000 0 000
000 0 000  000   000  000  000  0000
000   000  000   000  000  000   000
###

{ app, args, klog, post } = require 'kxk'

new app
    
    dir:        __dirname
    pkg:        require '../package.json'
    shortcut:   'Alt+K'
    onShortcut: -> post.toWins 'menuAction' 'Clear'
    index:      'index.html'
    icon:       '../img/app.ico'
    tray:       '../img/menu.png'
    about:      '../img/about.png'
    aboutDebug: false  
    args: """
        log     log every ms         0
        """
        
if args.log
    
    l = 0
    logm = ->
        l += 1
        klog 'log' l
        
    setInterval logm, args.log
    