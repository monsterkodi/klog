###
000   000  000  000   000  0000000     0000000   000   000  
000 0 000  000  0000  000  000   000  000   000  000 0 000  
000000000  000  000 0 000  000   000  000   000  000000000  
000   000  000  000  0000  000   000  000   000  000   000  
00     00  000  000   000  0000000     0000000   00     00  
###

{ post, stopEvent, setStyle, keyinfo, childp, slash, clamp, prefs, first, empty, open, udp, win, fs, error, log, _ } = require 'kxk'

{ Tail } = require 'tail'

Lines    = require './lines'
Search   = require './search'
Filter   = require './filter'
Find     = require './find'
  
log  = console.log
klog = require('kxk').log

window.lines = lines = new Lines

w = new win 
    dir:    __dirname
    pkg:    require '../package.json'
    menu:   '../coffee/menu.noon'
    icon:   '../img/menu@2x.png'
    onLoad: -> lines.onResize()

window.find   = new Find
window.search = new Search
window.filter = new Filter
    
logFile = slash.tilde slash.join w.userData, '..', 'klog.txt' 
findDir = slash.resolve prefs.get 'findDir', '~'

#  0000000   00000000   00000000  000   000  
# 000   000  000   000  000       0000  000  
# 000   000  00000000   0000000   000 0 000  
# 000   000  000        000       000  0000  
#  0000000   000        00000000  000   000  

koSend = null

openFile = (f) ->
  
    [file, line] = slash.splitFileLine f
    
    log 'openFile', file, line
    
    switch prefs.get 'editor', 'Visual Studio'
        when 'VS Code'
            open "vscode://file/" + slash.resolve f
        when 'Visual Studio'
            file = slash.unslash slash.resolve file
            bat = slash.unslash slash.resolve slash.join __dirname, '../bin/openFile/openVS.bat'
            childp.exec "\"#{bat}\" \"#{file}\" #{line} 0", { cwd:slash.dir(bat) }, (err) -> 
                error 'vb', err if not empty err
        when 'Atom'
            file = slash.unslash slash.resolve file
            atom = slash.unslash slash.untilde '~/AppData/Local/atom/bin/atom'
            childp.exec "\"#{atom}\" \"#{file}:#{line}\"", { cwd:slash.dir(file) }, (err) -> 
                error 'atom', err if not empty err
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
    
loadFile = (file) ->
    
    lines.clear()
    buffer = ''

    file = slash.untilde file
    stream = fs.createReadStream file, encoding:'utf8'
    stream.on 'data', (chunk) ->
        buffer += chunk
        while buffer.indexOf('\n') >= 0
            index  = buffer.indexOf('\n')
            data   = buffer.slice 0, index
            buffer = buffer.slice index+1
            try
                onMsg JSON.parse data
            catch err
                console.log "data:>#{data}<"
            
clearFile = (file) ->

    lines.clear()
    buffer = ''
    
    file = slash.untilde file
    fs.writeFile file, '', encoding:'utf8', (err) -> log 'cleared'
                
# 00000000   0000000   000   000  000000000      0000000  000  0000000  00000000
# 000       000   000  0000  000     000        000       000     000   000
# 000000    000   000  000 0 000     000        0000000   000    000    0000000
# 000       000   000  000  0000     000             000  000   000     000
# 000        0000000   000   000     000        0000000   000  0000000  00000000

defaultFontSize = 15

getFontSize = -> prefs.get 'fontSize', defaultFontSize

setFontSize = (s) ->
        
    s = getFontSize() if not _.isFinite s
    s = clamp 8, 44, s

    prefs.set 'fontSize', s
    lines.lines.style.fontSize = "#{s}px"
    iconSize = clamp 4, 44, parseInt s

    setStyle '.icon-column',     'height', "#{iconSize}px"
    setStyle '.icon-column img', 'height', "#{iconSize}px"
    setStyle '.icon-column .browserFileIcon::before', 'fontSize', "#{s}px"
    
    post.emit 'fontSize', s

window.setFontSize = setFontSize
    
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
     
# 000   000  000   000  00000000  00000000  000      
# 000 0 000  000   000  000       000       000      
# 000000000  000000000  0000000   0000000   000      
# 000   000  000   000  000       000       000      
# 00     00  000   000  00000000  00000000  0000000  

onWheel = (event) ->
    
    { mod, key, combo } = keyinfo.forEvent event

    if mod == 'ctrl'
        changeFontSize -event.deltaY/100
        stopEvent event
    
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
        when 'Load Log File'        then loadFile logFile 
        when 'Open Log File'        then openFile logFile 
        when 'Clear Log File'       then clearFile logFile 
        when 'Open Find Directory'  then openDir findDir
        when 'Clear'                then lines.clear()
        when 'Find'                 then post.emit 'focus', 'find'
        when 'Search'               then post.emit 'focus', 'search'
        when 'Exclude'              then post.emit 'focus', 'filter'
            
        when 'Visual Studio', 'VS Code', 'Atom', 'ko'
            setEditor action
            
        when 'ID', 'Num', 'Src', 'Icon', 'File', 'Time'
            lines.sizer.toggleDisplay action.toLowerCase()+'-column'
                
# 00     00   0000000   0000000   
# 000   000  000       000        
# 000000000  0000000   000  0000  
# 000 0 000       000  000   000  
# 000   000  0000000    0000000   

onMsg = (msg) ->
    
    if window.filter.shouldLog msg
        lines.appendLog msg

udpReceiver = new udp onMsg:onMsg #, debug:true
        
#  0000000  000000000  00000000   00000000   0000000   00     00    
# 000          000     000   000  000       000   000  000   000    
# 0000000      000     0000000    0000000   000000000  000000000    
#      000     000     000   000  000       000   000  000 0 000    
# 0000000      000     000   000  00000000  000   000  000   000    

tail = new Tail slash.untilde logFile
tail.on 'error', error
tail.on 'line', (line) -> 
    onMsg JSON.parse line
    
# 000  000   000  000  000000000    
# 000  0000  000  000     000       
# 000  000 0 000  000     000       
# 000  000  0000  000     000       
# 000  000   000  000     000       

prefs.set 'editor',  prefs.get 'editor', 'ko'
prefs.set 'findDir', prefs.get 'findDir', '~'

klog "editor:  #{prefs.get 'editor'}\nfindDir: #{prefs.get 'findDir'}\nlogFile: #{logFile}"

# setFontSize prefs.get 'fontSize', defaultFontSize

for column in ['id-column', 'src-column', 'icon-column', 'num-column', 'time-column']
    if not prefs.get "display:#{column}", true
        lines.sizer.toggleDisplay column
    