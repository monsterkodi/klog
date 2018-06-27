###
000      000  000   000  00000000   0000000
000      000  0000  000  000       000     
000      000  000 0 000  0000000   0000000 
000      000  000  0000  000            000
0000000  000  000   000  00000000  0000000 
###

{ post, elem, valid, slash, tooltip, log, str, $, _ } = require 'kxk'

class Lines

    constructor: ->
        
        @num = 0        
        @lines =$ '#lines'
        @icons = {}
        
        @lines.addEventListener 'click', @onClick

    appendLog: (msg) ->
        
        atBot = @lines.scrollTop > @lines.scrollHeight - @lines.clientHeight - 10
        
        @lines.appendChild @lineForLog msg
        
        window.search.apply @lines.lastChild
        window.filter.apply @lines.lastChild
        
        if @lines.children.length > 4000
            while @lines.children.length > 3600
                @lines.firstChild.remove()
                
        if atBot
            @lines.scrollTop = @lines.scrollHeight

    clear: -> @lines.innerHTML = ''
            
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
        html += "<span class='file'>#{slash.base(info.source) ? ''}</span>"
        html += "<span class='sep'>#{info.sep ? '⯈ '}</span>"
        html += "<span class='log'>#{str info.str}</span>"
        
        line = elem class:"line #{info.type}", html:html
        line.info = info
        
        icon =$ '.icon', line
        new tooltip elem:icon, parent:line, html:slash.tilde(info.source)
        
        line
    
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
