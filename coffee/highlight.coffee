###
000   000  000   0000000   000   000  000      000   0000000   000   000  000000000
000   000  000  000        000   000  000      000  000        000   000     000   
000000000  000  000  0000  000000000  000      000  000  0000  000000000     000   
000   000  000  000   000  000   000  000      000  000   000  000   000     000   
000   000  000   0000000   000   000  0000000  000   0000000   000   000     000   
###

{ matchr, valid, str, $, _ } = require 'kxk'

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
        
        lines = []
        
        if info.id == 'find'
            cfg  = window.search.cfg.concat window.find.cfg
            clss = 'find'
        else if info.id != 'file'
            clss = 'search'
            cfg  = window.search.cfg
        else
            cfg  = []
            
        for line in info.str.split '\n'
            
            rgs = matchr.ranges cfg, line
            rgs = rgs.concat Syntax.ranges line
            matchr.sortRanges rgs
            if valid rgs
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
                line = spans.join ''
            else
                line = str.encode line
            lines.push line
        
        div.innerHTML = lines.join '<br>'
        
module.exports = Highlight
