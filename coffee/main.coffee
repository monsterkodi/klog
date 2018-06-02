###
00     00   0000000   000  000   000
000   000  000   000  000  0000  000
000000000  000000000  000  000 0 000
000 0 000  000   000  000  000  0000
000   000  000   000  000  000   000
###

{ app, log } = require 'kxk'

new app
    dir:    __dirname
    pkg:    require '../package.json'
    args:   """

    noprefs     don't load preferences      false
    DevTools    open developer tools        false
    watch       watch sources for changes   false

    """
    shortcut:   'CmdOrCtrl+Alt+C'
    index:      'index.html'
    icon:       '../img/app.ico'
    tray:       '../img/menu.png'
    about:      '../img/about.png'
    aboutDebug: false
    single:     false
    