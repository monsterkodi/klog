###
000   000  000   0000000   000   000  000      000   0000000   000   000  000000000
000   000  000  000        000   000  000      000  000        000   000     000   
000000000  000  000  0000  000000000  000      000  000  0000  000000000     000   
000   000  000  000   000  000   000  000      000  000   000  000   000     000   
000   000  000   0000000   000   000  0000000  000   0000000   000   000     000   
###

{ $, kerror, klor, kstr, matchr, slash, valid } = require 'kxk'

klor = require 'klor'

class Highlight

    @lines: ->
        
        lines =$ '#lines'
        for line in lines.children
            Highlight.line line
            
    # 000      000  000   000  00000000  
    # 000      000  0000  000  000       
    # 000      000  000 0 000  0000000   
    # 000      000  000  0000  000       
    # 0000000  000  000   000  00000000  
    
    @line: (line) ->
        
        if not line?.info
            kerror "no info?" line
            return
        
        info = line.info
        div  =$ '.log-column' line
        
        # if info.highlighted and info.highlightSearch == window.search.text() and info.highlightFind = window.find.text()
            # div.innerHTML = info.highlighted
            # return
            
        cfg  = []
        
        ext  = info.ext ? 'log'
        if info.id == 'find'
            cfg  = window.search.cfg.concat window.find.cfg
            clss = 'find'
            ext  = slash.ext info.source
        else if info.id != 'file'
            clss = 'search'
            cfg  = window.search.cfg
            
        line = info.str
        rgs  = matchr.ranges(cfg, line).concat klor.ranges line, ext
        if valid rgs
            matchr.sortRanges rgs
            dss = matchr.dissect rgs
            info.highlightDiss = dss
            previ = 0
            spans = []
            for d in dss
                if d.start > previ
                    spans.push kstr.encode line.slice previ, d.start 
                previ = d.start+d.match.length
                spans.push "<span class='#{clss} #{d.clss}'>" + kstr.encode(d.match) + "</span>"
            if previ < line.length
                spans.push kstr.encode line.slice previ, line.length
            div.innerHTML = spans.join ''
        else
            delete info.highlightDiss
            div.innerHTML = kstr.encode line
            
        # info.highlighted     = div.innerHTML
        # info.highlightSearch = window.search.text()
        # info.highlightFind   = window.find.text()
        
module.exports = Highlight
