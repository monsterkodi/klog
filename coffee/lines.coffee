###
000      000  000   000  00000000   0000000
000      000  0000  000  000       000     
000      000  000 0 000  0000000   0000000 
000      000  000  0000  000            000
0000000  000  000   000  00000000  0000000 
###

{ post, tooltip, slash, empty, valid, elem, str, log, $, _ } = require 'kxk'

Scroll    = require './scroll'
ScrollBar = require './scrollbar'

class Lines

    constructor: ->
        
        @num = 0        
        @lines =$ '#lines'
        @icons = {}
        
        @scroll    = new Scroll @lines, 16
        @scrollBar = new ScrollBar @scroll
        
        @lines.addEventListener 'click', @onClick
        
        post.on 'fontSize', @onFontSize
        
        window.addEventListener 'resize', @onResize
        
    # 00000000   00000000   0000000  000  0000000  00000000  
    # 000   000  000       000       000     000   000       
    # 0000000    0000000   0000000   000    000    0000000   
    # 000   000  000            000  000   000     000       
    # 000   000  00000000  0000000   000  0000000  00000000  
    
    onResize: =>
        
        log 'onResize', @lines.clientHeight
        @scroll.setViewHeight @lines.parentNode.clientHeight

    onWheel: (delta) =>
        
        @scroll.by 5*@scroll.lineHeight * delta/100
        
    #  0000000   00000000   00000000   00000000  000   000  0000000    
    # 000   000  000   000  000   000  000       0000  000  000   000  
    # 000000000  00000000   00000000   0000000   000 0 000  000   000  
    # 000   000  000        000        000       000  0000  000   000  
    # 000   000  000        000        00000000  000   000  0000000    
    
    appendLog: (msg) -> 
        
        atBot = @lines.scrollTop > @lines.scrollHeight - @lines.clientHeight - 10
        
        line = @lineForLog msg
        line.info = msg
        @lines.appendChild line
        
        window.find.apply   @lines.lastChild
        window.search.apply @lines.lastChild
        window.filter.apply @lines.lastChild

        @scroll.setNumLines @lines.children.length
        
        if @lines.children.length > 4000
            while @lines.children.length > 3600
                @lines.firstChild.remove()
                
        if atBot
            @lines.scrollTop = @lines.scrollHeight
            
    clear: -> 
    
        @lines.innerHTML = ''
        @scroll.setNumLines 0
            
    # 000      000  000   000  00000000  
    # 000      000  0000  000  000       
    # 000      000  000 0 000  0000000   
    # 000      000  000  0000  000       
    # 0000000  000  000   000  00000000  
    
    lineForLog: (info) ->
        
        icon = 
            if info.icon 
                if info.icon.startsWith 'file://' then "<img src='#{info.icon}'/>" else info.icon
            else if @icons[info.id]
                "<img src='#{@icons[info.id]}'/>"
            else
                file = slash.join __dirname, "../img/#{info.id}.png"
                @icons[info.id] = slash.fileUrl if slash.exists file then file else slash.join __dirname, "../img/blank.png"
                "<img src='#{@icons[info.id]}'/>"
        
        @num  += 1
        html  = ""
        
        html += "<span class='src'>#{info.source ? ''}"
        if info.line
            html += "<span class='ln'>:#{info.line}</span>"
            if info.column
                html += "<span class='col'>:#{info.column}</span>"
        html += "</span>"
        
        d = new Date()
        time = ["#{_.padStart(String(d.getHours()),   2, '0')}"
                "#{_.padStart(String(d.getMinutes()), 2, '0')}"
                "#{_.padStart(String(d.getSeconds()), 2, '0')}"].join ':' 
        
        html += "<span class='num'>#{@num}</span>"
        html += "<span class='icon'>#{icon}</span>"
        html += "<span class='time'>#{time}</span>"
        html += "<span class='id'>#{info.id ? ''}</span>"
        html += "<span class='file'>#{info.file ? slash.base(info.source) ? ''}</span>"
        html += "<span class='sep'>#{info.sep ? '⯈ '}</span>"
    
        logStr = info.str.split('\n').map((s) -> str.encode s).join '<br>'
        html += "<span class='log'>#{logStr}</span>"
        
        line = elem class:"line #{info.type}", html:html
        # line.info = info
        
        icon =$ '.icon', line
        new tooltip elem:icon, parent:line, html:slash.tilde(info.source)
        
        line
    
    # 00000000   0000000   000   000  000000000
    # 000       000   000  0000  000     000
    # 000000    000   000  000 0 000     000
    # 000       000   000  000  0000     000
    # 000        0000000   000   000     000

    onFontSize: (size) =>
        
        return if not @lines?

        if not @lines.firstChild
            @appendLog file:'', source:'', id:'', str:'Text'
        
        lineHeight = @lines.firstChild.clientHeight
        if lineHeight > 0
            @scroll?.setLineHeight lineHeight

    #  0000000  000      000   0000000  000   000  
    # 000       000      000  000       000  000   
    # 000       000      000  000       0000000    
    # 000       000      000  000       000  000   
    #  0000000  0000000  000   0000000  000   000  
    
    onClick: (event) ->
        
        return if event.target.classList.contains 'log'
        return if event.target.classList.contains 'line'
        
        if lineElem = elem.upElem event.target, class:'line'
            file =  $('.src', lineElem).innerText
            if valid file
                
                file = file.replace /[\w\-]+\-x64\/resources\/app\//, ''
                
                if /\/node\_modules\//.test file
                    upFile = file.replace /[\w\-]+\/node\_modules\//, ''
                    if slash.exists upFile
                        file = upFile
                    
                post.emit 'openFile', file
            
module.exports = Lines
