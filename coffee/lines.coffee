###
000      000  000   000  00000000   0000000
000      000  0000  000  000       000     
000      000  000 0 000  0000000   0000000 
000      000  000  0000  000            000
0000000  000  000   000  00000000  0000000 
###

{ post, setStyle, valid, prefs, slash, empty, elem, str, $, _ } = require 'kxk'

log = console.log
Scroll    = require './scroll'
ScrollBar = require './scrollbar'
Highlight = require './highlight'
fileIcons = require 'file-icons-js'

class Lines

    constructor: ->
        
        @num = 0        
        @lines =$ '#lines'
        @cache = []
        @icons = {}
        
        @scroll    = new Scroll @lines
        @scrollBar = new ScrollBar @scroll
        
        @lines.addEventListener 'click', @onClick
        
        post.on 'fontSize', @onFontSize
        post.on 'showLines', @onShowLines 
        post.on 'shiftLines', @onShiftLines
        post.on 'clearLines', @onClearLines
        post.on 'changeLines', @onChangeLines
        
        window.addEventListener 'resize', @onResize

    #  0000000  000      00000000   0000000   00000000   
    # 000       000      000       000   000  000   000  
    # 000       000      0000000   000000000  0000000    
    # 000       000      000       000   000  000   000  
    #  0000000  0000000  00000000  000   000  000   000  
    
    onClearLines: =>
        
        log 'onClearLines'
        @num = 0  
        @lines.innerHTML = ''
        
    # 000   000  00000000   0000000     0000000   000000000  00000000  00000000    0000000    0000000  
    # 000   000  000   000  000   000  000   000     000     000       000   000  000   000  000       
    # 000   000  00000000   000   000  000000000     000     0000000   00000000   000   000  0000000   
    # 000   000  000        000   000  000   000     000     000       000        000   000       000  
    #  0000000   000        0000000    000   000     000     00000000  000         0000000   0000000   
    
    updatePositions: =>
        
        li = 0
        
        # log 'updatePositions:', @lines.children.length
                    
        for div in @lines.children
            y = @scroll.lineHeight * li
            div.style.transform = "translate3d(0,#{y}px, 0)"
            div.style.zIndex = li
            li++
        
    #  0000000   00000000   00000000   00000000  000   000  0000000    
    # 000   000  000   000  000   000  000       0000  000  000   000  
    # 000000000  00000000   00000000   0000000   000 0 000  000   000  
    # 000   000  000        000        000       000  0000  000   000  
    # 000   000  000        000        00000000  000   000  0000000    
    
    appendLine: (lineIndex) ->
        
        if lineIndex > @cache.length-1
            return
        
        line = @cache[lineIndex]
        Highlight.line line

        @lines.appendChild line        
        
    # 00000000   00000000   00000000  00000000   00000000  000   000  0000000    
    # 000   000  000   000  000       000   000  000       0000  000  000   000  
    # 00000000   0000000    0000000   00000000   0000000   000 0 000  000   000  
    # 000        000   000  000       000        000       000  0000  000   000  
    # 000        000   000  00000000  000        00000000  000   000  0000000    
    
    prependLine: (lineIndex) ->
        
        if lineIndex < 0 or lineIndex > @cache.length-1
            log "skip prepend #{lineIndex}"
            return 
        
        line = @cache[lineIndex]
        Highlight.line line
        
        @lines.insertBefore line, @lines.firstChild
    
    shiftLine: (lineIndex) ->
        # log "Lines.shiftLine lineIndex:#{lineIndex}"
        
        if lineIndex >= 0 and lineIndex <= @cache.length-1 
            @lines.firstChild.remove() # this should check if line matches!
        # else 
            # log "skip shift #{lineIndex}"
        
    popLine: (lineIndex) ->
        # log "Lines.popLine lineIndex:#{lineIndex}"
        
        if lineIndex <= @cache.length-1 
            @lines.lastChild.remove() # this should check if line matches!
        # else 
            # log "skip pop #{lineIndex}"
        
    #  0000000  000   000   0000000   000   000  
    # 000       000   000  000   000  000 0 000  
    # 0000000   000000000  000   000  000000000  
    #      000  000   000  000   000  000   000  
    # 0000000   000   000   0000000   00     00  
    
    onShowLines: (top, bot, num) =>
        
        # log "Lines.onShowLines top:#{top} bot:#{bot} num:#{num} cache:#{@cache.length}"
        
        @lines.innerHTML = ''
        for li in [top..bot]
            @appendLine li
            
        if valid(@cache) and @scroll.lineHeight <= prefs.get 'fontSize'
            # log 'onShowLines delayedFontSize'
            @onFontSize prefs.get 'fontSize', 16
        
        @updatePositions()
        
    #  0000000  000   000   0000000   000   000   0000000   00000000  
    # 000       000   000  000   000  0000  000  000        000       
    # 000       000000000  000000000  000 0 000  000  0000  0000000   
    # 000       000   000  000   000  000  0000  000   000  000       
    #  0000000  000   000  000   000  000   000   0000000   00000000  
    
    onChangeLines: (oldLines, newLines) =>
        
        while newLines > oldLines
            @appendLine oldLines++
            
        while newLines < oldLines
            @popLine oldLines
            oldLines--
            
        @updatePositions()            
            
    #  0000000  000   000  000  00000000  000000000  
    # 000       000   000  000  000          000     
    # 0000000   000000000  000  000000       000     
    #      000  000   000  000  000          000     
    # 0000000   000   000  000  000          000     
    
    onShiftLines: (top, bot, num) =>
        # log 'onShiftLines', top, bot, num
        if num > 0
            for n in [0...num]
                # log 'onShiftLines shift', top-num+n, 'append', bot-num+n+1, @cache.length
                @shiftLine  top-num+n
                @appendLine bot-num+n+1
        else
            for n in [0...-num]
                # log 'onShiftLines prepend', top-num-n-1, 'pop', bot-num-n, top-num-n-1
                @popLine     bot-num-n
                @prependLine top-num-n-1
                
        @updatePositions()
    
    # 00000000   00000000   0000000  000  0000000  00000000  
    # 000   000  000       000       000     000   000       
    # 0000000    0000000   0000000   000    000    0000000   
    # 000   000  000            000  000   000     000       
    # 000   000  00000000  0000000   000  0000000  00000000  
    
    onResize: =>
        
        @scroll.setViewHeight @lines.parentNode.clientHeight

    # 000   000  000   000  00000000  00000000  000      
    # 000 0 000  000   000  000       000       000      
    # 000000000  000000000  0000000   0000000   000      
    # 000   000  000   000  000       000       000      
    # 00     00  000   000  00000000  00000000  0000000  
    
    onWheel: (event) =>
        
        scrollFactor = ->
            f  = 1
            f *= 1 + 1 * event.shiftKey
            f *= 1 + 3 * event.ctrlKey
            f *= 1 + 7 * event.altKey
        
        delta = event.deltaY * scrollFactor()
        
        # @scroll.by @scroll.lineHeight * delta/200
        @scroll.by 5 * @scroll.lineHeight * delta/100
        
    #  0000000   00000000   00000000   00000000  000   000  0000000    
    # 000   000  000   000  000   000  000       0000  000  000   000  
    # 000000000  00000000   00000000   0000000   000 0 000  000   000  
    # 000   000  000        000        000       000  0000  000   000  
    # 000   000  000        000        00000000  000   000  0000000    
    
    appendLog: (msg) -> 
                
        line = @lineForLog msg
        
        @cache.push line
        
        @scroll.setNumLines @cache.length

        if @lines.children.length <= @scroll.bot-@scroll.top
            @appendLine @cache.length-1
            @updatePositions()
        
    clear: -> 
    
        @scroll.setNumLines 0
        @cache = []
            
    # 000      000  000   000  00000000  
    # 000      000  0000  000  000       
    # 000      000  000 0 000  0000000   
    # 000      000  000  0000  000       
    # 0000000  000  000   000  00000000  
    
    lineForLog: (info) ->
        
        info        ?= sep:''
        info.sep    ?= '⯈ '
        info.id     ?= ''
        info.str    ?= ''
        info.source ?= ''
        info.type   ?= ''
        info.file   ?= slash.base info.source
        
        icon =
            if info.icon?
                if info.icon.startsWith 'file://' then "<img src='#{info.icon}'/>" else info.icon
            else if @icons[info.id]
                "<img src='#{@icons[info.id]}'/>"
            else if info.id == 'file'
                className = fileIcons.getClass slash.removeLinePos info.source
                if empty className
                    if slash.ext(info.source) == 'noon'
                        className = 'noon-icon'
                    else
                        className = 'file-icon'
                "<div class=\"#{className} browserFileIcon\"></div>"
            else if valid info.id
                file = slash.join __dirname, "../img/#{info.id}.png"
                @icons[info.id] = slash.fileUrl if slash.exists file then file else slash.join __dirname, "../img/blank.png"
                "<img src='#{@icons[info.id]}'/>"
            else
                ''
        info.icon ?= icon
                
        @num  += 1
        
        fileClss = 'file'
        iconClss = 'icon'
        idClss   = 'id'
        logClss  = 'log'
        srcClss  = 'src'
        
        if info.source?
            ext = slash.ext info.source
            fileClss += ' ' + ext
            iconClss += ' ' + ext
            idClss   += ' ' + ext
            srcClss   += ' ' + ext
            if info.type == 'file'
                logClss  += ' ' + ext
        
        html  = ""
        
        d = new Date()
        time = ["#{_.padStart(String(d.getHours()),   2, '0')}"
                "#{_.padStart(String(d.getMinutes()), 2, '0')}"
                "#{_.padStart(String(d.getSeconds()), 2, '0')}"
                "#{_.padStart(String(d.getMilliseconds()), 2, '0')}"].join ':' 
                        
        html += "<span class='num'>#{@num-1}</span>"
        html += "<span class='time'>#{time}</span>"
        html += "<span class='#{iconClss}'>#{icon}</span>"
        html += "<span class='#{idClss}'>#{info.id} </span>"            
        html += "<span class='#{fileClss}'>#{info.file} </span>"
        html += "<span class='sep'>#{info.sep}</span>"
    
        logStr = info.str.split('\n').map((s) -> str.encode s).join '<br>'
        html += "<span class='#{logClss}'>#{logStr}</span>"
        html += "<span class='#{srcClss}'>#{info.source ? ''}"
        if info.line
            html += "<span class='ln'>:#{info.line}</span>"
            if info.column
                html += "<span class='col'>:#{info.column}</span>"
        html += "</span>"
        
        line = elem class:"line #{info.type}", html:html
        # line.info = info
        
        # icon =$ '.icon', line
        # new tooltip elem:icon, parent:line, html:slash.tilde(info.source)
        
        line.info = info
        line
    
    # 00000000   0000000   000   000  000000000       0000000  000  0000000  00000000  
    # 000       000   000  0000  000     000         000       000     000   000       
    # 000000    000   000  000 0 000     000         0000000   000    000    0000000   
    # 000       000   000  000  0000     000              000  000   000     000       
    # 000        0000000   000   000     000         0000000   000  0000000  00000000  

    onFontSize: (size) =>
        return if not @lines?
        if @lines.firstChild
            setStyle '.line', 'height', ''
            lineHeight = @lines.firstChild.clientHeight
            if lineHeight > 0
                @scroll?.setLineHeight lineHeight
                setStyle '.line', 'height', "#{lineHeight}px"
        else if size > 0
            @scroll?.setLineHeight size
            setStyle '.line', 'height', "#{lineHeight}px"

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
