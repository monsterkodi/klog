###
000   000  000  000   000  0000000     0000000   000   000  
000 0 000  000  0000  000  000   000  000   000  000 0 000  
000000000  000  000 0 000  000   000  000   000  000000000  
000   000  000  000  0000  000   000  000   000  000   000  
00     00  000  000   000  0000000     0000000   00     00  
###

{ win, elem, empty, post, childp, slash, udp, str, $ } = require 'kxk'

log = console.log

w = new win 
    dir:    __dirname
    pkg:    require '../package.json'
    menu:   '../coffee/menu.noon'
    icon:   '../img/menu@2x.png'
    
lines =$ '#lines'

#  0000000   00000000   00000000  000   000  
# 000   000  000   000  000       0000  000  
# 000   000  00000000   0000000   000 0 000  
# 000   000  000        000       000  0000  
#  0000000   000        00000000  000   000  

koSend = null
openFile = (f) ->
    
    if not koSend
        koSend = new udp port:9779
    koSend.send slash.resolve f
    
    # f = slash.resolve f
    # if slash.win()
        # log 'openFile', f, slash.unslash slash.resolve('~/s/ko/ko-win32-x64/ko.exe')
        # childp.spawn slash.unslash(slash.resolve('~/s/ko/ko-win32-x64/ko.exe')), ['ko', slash.unslash slash.path f]
    # else
        # childp.spawn '/usr/local/bin/ko', [f]

#  0000000  000      000   0000000  000   000  
# 000       000      000  000       000  000   
# 000       000      000  000       0000000    
# 000       000      000  000       000  000   
#  0000000  0000000  000   0000000  000   000  

onClick = (event) ->
    
    if lineElem = elem.upElem event.target, class:'line'
        file =  lineElem.children[3].innerText
        log 'click', file
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

onMenuAction = (action) ->
    
    switch action
        when 'Clear' 
            lines.innerHTML = ''
            lineNo = 0
        
post.on 'menuAction', onMenuAction

# 000   000  000000000  00     00  000      
# 000   000     000     000   000  000      
# 000000000     000     000000000  000      
# 000   000     000     000 0 000  000      
# 000   000     000     000   000  0000000  

num = 0
htmlForLog = (info) ->
    
    num  += 1
    html  = "<span class='num'>#{num}</span>"
    html += "<span class='icon'>#{info.icon ? ''}</span>"
    html += "<span class='id'>#{info.id ? ''}</span>"
    html += "<span class='src'>#{info.source ? ''}"
    if info.line
        html += "<span class='ln'>:#{info.line}</span>"
        if info.column
            html += "<span class='col'>:#{info.column}</span>"
    html += "</span>"
    if info.name?
        html += "<span class='name'>#{info.name}</span>"
    html += "<span class='log'>#{str info.str}</span>"
    html

# 00     00   0000000   0000000   
# 000   000  000       000        
# 000000000  0000000   000  0000  
# 000 0 000       000  000   000  
# 000   000  0000000    0000000   

onMsg = (args) ->
    
    console.log 'onMsg', args
    atBot = lines.scrollTop > lines.scrollHeight - lines.clientHeight - 10
    
    lines.appendChild elem class:'line', html:htmlForLog args
    
    if lines.children.length > 4000
        while lines.children.length > 3600
            lines.firstChild.remove()
            
    if atBot
        lines.scrollTop = lines.scrollHeight

udpReceiver = new udp onMsg:onMsg, debug:true

