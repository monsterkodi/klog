###
000   000  000   0000000   000   000  000      000   0000000   000   000  000000000
000   000  000  000        000   000  000      000  000        000   000     000   
000000000  000  000  0000  000000000  000      000  000  0000  000000000     000   
000   000  000  000   000  000   000  000      000  000   000  000   000     000   
000   000  000   0000000   000   000  0000000  000   0000000   000   000     000   
###

{ matchr, slash, valid, str, log, $ } = require 'kxk'

log = console.log
Syntax = require './syntax'

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
        
        info  = line.info
        div   =$ '.log', line
        
        if info.highlighted and info.highlightSearch == window.search.text() and info.highlightFind = window.find.text()
            div.innerHTML = info.highlighted
            return
            
        cfg  = []
        
        if info.id == 'find'
            cfg  = window.search.cfg.concat window.find.cfg
            clss = 'find'
        else if info.id != 'file'
            clss = 'search'
            cfg  = window.search.cfg
            
        line = info.str
        rgs  = matchr.ranges(cfg, line).concat Syntax.ranges line, slash.ext info.source
        if valid rgs
            matchr.sortRanges rgs
            dss = matchr.dissect rgs
            previ = 0
            spans = []
            for d in dss
                if d.start > previ
                    spans.push str.encode line.slice previ, d.start 
                previ = d.start+d.match.length
                spans.push "<span class='#{clss} #{d.clss}'>" + str.encode(d.match) + "</span>"
            if previ < line.length
                spans.push str.encode line.slice previ, line.length
            div.innerHTML = spans.join ''
        else
            div.innerHTML = str.encode line
            
        info.highlighted     = div.innerHTML
        info.highlightSearch = window.search.text()
        info.highlightFind   = window.find.text()
        
module.exports = Highlight
