###
000   000  000  000   000  0000000     0000000   000   000  
000 0 000  000  0000  000  000   000  000   000  000 0 000  
000000000  000  000 0 000  000   000  000   000  000000000  
000   000  000  000  0000  000   000  000   000  000   000  
00     00  000  000   000  0000000     0000000   00     00  
###

{ post, win, open, prefs, elem, setStyle, getStyle, empty, childp, slash, udp, str, fs, error, $ } = require 'kxk'

log = console.log

w = new win 
    dir:    __dirname
    pkg:    require '../package.json'
    menu:   '../coffee/menu.noon'
    icon:   '../img/menu@2x.png'
    
lines =$ '#lines'
icons = {}

#  0000000   00000000   00000000  000   000  
# 000   000  000   000  000       0000  000  
# 000   000  00000000   0000000   000 0 000  
# 000   000  000        000       000  0000  
#  0000000   000        00000000  000   000  

koSend = null
openFile = (f) ->
  
    [file, line] = slash.splitFileLine f
    
    switch prefs.get 'editor', 'Visual Studio'
        when 'VS Code'
            open "vscode://file/" + slash.resolve f
        when 'Visual Studio'
            [file, line] = slash.splitFileLine f
            file = slash.resolve file
            vb = slash.resolve slash.join __dirname, '../bin/openFile/openVS.bat'
            childp.exec "#{vb} #{file} #{line} 0", { cwd:slash.dir vb }, (err) -> 
                error 'vb', err if not empty err
        else
            if not koSend then koSend = new udp port:9779
            koSend.send slash.resolve f
    
#  0000000  000      000   0000000  000   000  
# 000       000      000  000       000  000   
# 000       000      000  000       0000000    
# 000       000      000  000       000  000   
#  0000000  0000000  000   0000000  000   000  

onClick = (event) ->
    
    if lineElem = elem.upElem event.target, class:'line'
        file =  lineElem.children[3].innerText
        if not empty file
            openFile file

lines.addEventListener 'click', onClick

#  0000000   0000000   00     00  0000000     0000000   
# 000       000   000  000   000  000   000  000   000  
# 000       000   000  000000000  0000000    000   000  
# 000       000   000  000 0 000  000   000  000   000  
#  0000000   0000000   000   000  0000000     0000000   

post.on 'combo', (combo, info) -> 
    switch combo
        when 'home'      then lines.scrollTop = 0
        when 'end'       then lines.scrollTop = lines.scrollHeight
        when 'page up'   then lines.scrollTop -= 1000
        when 'page down' then lines.scrollTop += 1000
        else
            log 'combo', combo

# 00     00  00000000  000   000  000   000   0000000    0000000  000000000  000   0000000   000   000  
# 000   000  000       0000  000  000   000  000   000  000          000     000  000   000  0000  000  
# 000000000  0000000   000 0 000  000   000  000000000  000          000     000  000   000  000 0 000  
# 000 0 000  000       000  0000  000   000  000   000  000          000     000  000   000  000  0000  
# 000   000  00000000  000   000   0000000   000   000   0000000     000     000   0000000   000   000  

setEditor = (editor) ->
    
    prefs.set 'editor', editor
    require('kxk').log "using editor: #{prefs.get 'editor'}"

post.on 'menuAction', (action) ->
    
    switch action
        when 'Clear' 
            lines.innerHTML = ''
            lineNo = 0
        when 'Visual Studio', 'VS Code', 'ko'
            setEditor action
            
        when 'ID', 'Num', 'Src', 'Icon'
            toggleDisplay action.toLowerCase()
        
# 000      000  000   000  00000000  
# 000      000  0000  000  000       
# 000      000  000 0 000  0000000   
# 000      000  000  0000  000       
# 0000000  000  000   000  00000000  

num = 0
lineForLog = (info) ->
    
    icon = 
        if info.icon 
            if info.icon.startsWith 'file://' then "<img src='#{info.icon}'/>" else info.icon
        else if icons[info.id]
            "<img src='#{icons[info.id]}'/>"
        else
            file = slash.join __dirname, "../img/#{info.id}.png"
            icons[info.id] = slash.fileUrl if slash.exists file then file else slash.join __dirname, "../img/blank.png"
            "<img src='#{icons[info.id]}'/>"
    
    num  += 1
    html  = ""
    html += "<span class='num'>#{num}</span>"
    html += "<span class='icon'>#{icon}</span>"
    html += "<span class='id'>#{info.id ? ''}</span>"
    html += "<span class='src'>#{info.source ? ''}"
    if info.line
        html += "<span class='ln'>:#{info.line}</span>"
        if info.column
            html += "<span class='col'>:#{info.column}</span>"
    html += "</span>"
    html += "<span class='log'>#{str info.str}</span>"
    
    elem class:"line #{info.type}", html:html


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
    
    # log 'onMsg', args
    atBot = lines.scrollTop > lines.scrollHeight - lines.clientHeight - 10
    
    lines.appendChild lineForLog args
    
    if lines.children.length > 4000
        while lines.children.length > 3600
            lines.firstChild.remove()
            
    if atBot
        lines.scrollTop = lines.scrollHeight

udpReceiver = new udp onMsg:onMsg, debug:true

setEditor prefs.get 'editor'

for column in ['id', 'src', 'icon', 'num']
    if not prefs.get "display:#{column}", true
        toggleDisplay column
