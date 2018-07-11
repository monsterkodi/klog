###
000   000  000  000   000  0000000     0000000   000   000  
000 0 000  000  0000  000  000   000  000   000  000 0 000  
000000000  000  000 0 000  000   000  000   000  000000000  
000   000  000  000  0000  000   000  000   000  000   000  
00     00  000  000   000  0000000     0000000   00     00  
###

{ post, setStyle, getStyle, childp, empty, prefs, slash, first, clamp, open, args, win, udp, error, log, _ } = require 'kxk'

{ Tail } = require 'tail'

Lines  = require './lines'
Search = require './search'
Filter = require './filter'
Find   = require './find'
  
log  = console.log
klog = require('kxk').log

w = new win 
    dir:    __dirname
    pkg:    require '../package.json'
    menu:   '../coffee/menu.noon'
    icon:   '../img/menu@2x.png'
    
logFile = slash.join w.userData, '..', 'klog.txt' 
findDir = slash.resolve prefs.get 'findDir', '~'

window.lines  = lines = new Lines
window.find   = new Find
window.search = new Search
window.filter = new Filter

#  0000000   00000000   00000000  000   000  
# 000   000  000   000  000       0000  000  
# 000   000  00000000   0000000   000 0 000  
# 000   000  000        000       000  0000  
#  0000000   000        00000000  000   000  

koSend = null
ueSend = null

openFile = (f) ->
  
    [file, line] = slash.splitFileLine f
    
    log 'openFile', file, line
    
    if file.startsWith '/Game/'
        log 'UESEND!', file
        if not ueSend 
            ueSend = new udp port:9889
        ueSend.send file
        return
    
    switch prefs.get 'editor', 'Visual Studio'
        when 'VS Code'
            open "vscode://file/" + slash.resolve f
        when 'Visual Studio'
            file = slash.unslash slash.resolve file
            bat = slash.unslash slash.resolve slash.join __dirname, '../bin/openFile/openVS.bat'
            childp.exec "\"#{bat}\" \"#{file}\" #{line} 0", { cwd:slash.dir(bat) }, (err) -> 
                error 'vb', err if not empty err
        else
            if not koSend then koSend = new udp port:9779
            koSend.send slash.resolve f
    
post.on 'openFile', openFile

openDir = (dir) ->
    
    opts =
        title:      'Open'
        properties: ['openDirectory']
    
    electron = require 'electron'
    electron.remote.dialog.showOpenDialog opts, (dirs) =>
        if dir = first dirs
            slash.dirExists dir, ->
                setFindDir dir
                
setFindDir = (dir) ->
    
    findDir = slash.tilde dir
    prefs.set 'findDir', findDir
    klog 'findDir', findDir
            
#  0000000   0000000   00     00  0000000     0000000   
# 000       000   000  000   000  000   000  000   000  
# 000       000   000  000000000  0000000    000   000  
# 000       000   000  000 0 000  000   000  000   000  
#  0000000   0000000   000   000  0000000     0000000   

post.on 'combo', (combo, info) -> 
    
    switch combo
        when 'home'      then lines.lines.scrollTop = 0
        when 'end'       then lines.lines.scrollTop = lines.scrollHeight
        when 'page up'   then lines.lines.scrollTop -= 1000
        when 'page down' then lines.lines.scrollTop += 1000

# 00000000   0000000   000   000  000000000      0000000  000  0000000  00000000
# 000       000   000  0000  000     000        000       000     000   000
# 000000    000   000  000 0 000     000        0000000   000    000    0000000
# 000       000   000  000  0000     000             000  000   000     000
# 000        0000000   000   000     000        0000000   000  0000000  00000000

defaultFontSize = 15

getFontSize = -> prefs.get 'fontSize', defaultFontSize

setFontSize = (s) ->
        
    s = getFontSize() if not _.isFinite s
    s = clamp 4, 44, s

    prefs.set "fontSize", s
    lines.lines.style.fontSize = "#{s}px"
    iconSize = clamp 4, 44, parseInt s

    setStyle '.icon',     'height', "#{iconSize}px"
    setStyle '.icon img', 'height', "#{iconSize}px"

changeFontSize = (d) ->
    
    s = getFontSize()
    if      s >= 30 then f = 4
    else if s >= 50 then f = 10
    else if s >= 20 then f = 2
    else                 f = 1
        
    setFontSize s + f*d

resetFontSize = ->
    
    prefs.set 'fontSize', defaultFontSize
    setFontSize defaultFontSize
     
onWheel = (event) ->
    
    if 0 <= w.modifiers.indexOf 'ctrl'
        changeFontSize -event.deltaY/100
    
window.document.addEventListener 'wheel', onWheel    
    
# 00     00  00000000  000   000  000   000   0000000    0000000  000000000  000   0000000   000   000  
# 000   000  000       0000  000  000   000  000   000  000          000     000  000   000  0000  000  
# 000000000  0000000   000 0 000  000   000  000000000  000          000     000  000   000  000 0 000  
# 000 0 000  000       000  0000  000   000  000   000  000          000     000  000   000  000  0000  
# 000   000  00000000  000   000   0000000   000   000   0000000     000     000   0000000   000   000  

setEditor = (editor) ->
    
    prefs.set 'editor', editor
    klog "editor: #{prefs.get 'editor'}"

post.on 'menuAction', (action) ->
    
    switch action
        
        when 'Increase'             then changeFontSize +1
        when 'Decrease'             then changeFontSize -1
        when 'Reset'                then resetFontSize()
        when 'Open Log File'        then openFile logFile 
        when 'Open Find Directory'  then openDir findDir
        when 'Clear'                then lines.clear()
        when 'Find'                 then post.emit 'focus', 'find'
        when 'Search'               then post.emit 'focus', 'search'
        when 'Exclude'              then post.emit 'focus', 'filter'
            
        when 'Visual Studio', 'VS Code', 'ko'
            setEditor action
            
        when 'ID', 'Num', 'Src', 'Icon', 'File', 'Time'
            toggleDisplay action.toLowerCase()
        
toggleDisplay = (column) ->
    
    key = "#lines div span.#{column}"
    if 'none' == getStyle key, 'display'
        prefs.set "display:#{column}", true
        setStyle key, 'display', 'inline-block'
    else
        prefs.set "display:#{column}", false
        setStyle key, 'display', 'none'
    
# 00     00   0000000   0000000   
# 000   000  000       000        
# 000000000  0000000   000  0000  
# 000 0 000       000  000   000  
# 000   000  0000000    0000000   

onMsg = (args) ->
    log 'onMsg', args
    lines.appendLog args

udpReceiver = new udp onMsg:onMsg #, debug:true
        
#  0000000  000000000  00000000   00000000   0000000   00     00    
# 000          000     000   000  000       000   000  000   000    
# 0000000      000     0000000    0000000   000000000  000000000    
#      000     000     000   000  000       000   000  000 0 000    
# 0000000      000     000   000  00000000  000   000  000   000    

log 'logFile:', logFile
tail = new Tail logFile
tail.on 'error', error
tail.on 'line', (line) -> 
    onMsg JSON.parse line
    
# 000  000   000  000  000000000    
# 000  0000  000  000     000       
# 000  000 0 000  000     000       
# 000  000  0000  000     000       
# 000  000   000  000     000       

setEditor   prefs.get 'editor', 'ko'
setFindDir  prefs.get 'findDir', '~'
setFontSize prefs.get 'fontSize', defaultFontSize

for column in ['id', 'src', 'icon', 'num', 'time']
    if not prefs.get "display:#{column}", true
        toggleDisplay column
    