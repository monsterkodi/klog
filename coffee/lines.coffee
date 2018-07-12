###
000      000  000   000  00000000   0000000
000      000  0000  000  000       000     
000      000  000 0 000  0000000   0000000 
000      000  000  0000  000            000
0000000  000  000   000  00000000  0000000 
###

{ post, setStyle, tooltip, slash, valid, elem, str, $, _ } = require 'kxk'

log = console.log
Scroll    = require './scroll'
ScrollBar = require './scrollbar'

class Lines

    constructor: ->
        
        @num = 0        
        @lines =$ '#lines'
        @cache = []
        @icons = {}
        
        @scroll    = new Scroll @lines, 16
        @scrollBar = new ScrollBar @scroll
        
        @lines.addEventListener 'click', @onClick
        
        post.on 'fontSize', @onFontSize
        post.on 'showLines', @onShowLines 
        post.on 'shiftLines', @onShiftLines
        post.on 'clearLines', @onClearLines
        
        window.addEventListener 'resize', @onResize
        
    onClearLines: => 
        
        log 'onClearLines'
        @num = 0  
        @lines.innerHTML = ''
        
    appendLine: (line) ->
        
        window.find.apply   line
        window.search.apply line
        # window.filter.apply line
        # log 'append line', line
        @lines.appendChild  line
        
    prependLine: (line) ->
        return if not line
        # log 'prepend line', line
        window.find.apply   line
        window.search.apply line
        @lines.insertBefore line, @lines.firstChild
        
    onShowLines: (top, bot, num) =>
        
        log 'onShowLines', top, bot, num
        @lines.innerHTML = ''
        for li in [top..bot]
            # log 'appendLine', li
            @appendLine @cache[li]
        
    onShiftLines: (top, bot, num) =>
        
        # log 'onShiftLines', top, bot, num
        
        if num > 0
            for n in [0...num]
                @lines.firstChild.remove()
                @appendLine @cache[bot-num+n]
        else
            for n in [0...-num]
                @lines.lastChild.remove()
                @prependLine @cache[top-num-n]
    
    # 00000000   00000000   0000000  000  0000000  00000000  
    # 000   000  000       000       000     000   000       
    # 0000000    0000000   0000000   000    000    0000000   
    # 000   000  000            000  000   000     000       
    # 000   000  00000000  0000000   000  0000000  00000000  
    
    onResize: =>
        
        # log 'onResize', @lines.clientHeight
        @scroll.setViewHeight @lines.parentNode.clientHeight

    onWheel: (delta) =>
        
        @scroll.by 5*@scroll.lineHeight * delta/100
        
    #  0000000   00000000   00000000   00000000  000   000  0000000    
    # 000   000  000   000  000   000  000       0000  000  000   000  
    # 000000000  00000000   00000000   0000000   000 0 000  000   000  
    # 000   000  000        000        000       000  0000  000   000  
    # 000   000  000        000        00000000  000   000  0000000    
    
    appendLog: (msg) -> 
        
        line = @lineForLog msg
        line.info = msg
        
        @cache.push line
        
        @scroll.setNumLines @cache.length

        if @lines.children.length < @scroll.bot-@scroll.top
            @appendLine line
        
    clear: -> 
    
        @scroll.setNumLines 0
        @cache = []
            
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
        
        # icon =$ '.icon', line
        # new tooltip elem:icon, parent:line, html:slash.tilde(info.source)
        
        line
    
    # 00000000   0000000   000   000  000000000
    # 000       000   000  0000  000     000
    # 000000    000   000  000 0 000     000
    # 000       000   000  000  0000     000
    # 000        0000000   000   000     000

    onFontSize: (size) =>
        
        return if not @lines?

        return if not @lines.firstChild
        # if not @lines.firstChild
            # @appendLog file:'', source:'', id:'', str:'Text'
        
        setStyle '.line', 'height', ""
            
        lineHeight = @lines.firstChild.clientHeight
        if lineHeight > 0
            @scroll?.setLineHeight lineHeight
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
