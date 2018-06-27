###
 0000000  00000000   0000000   00000000    0000000  000   000
000       000       000   000  000   000  000       000   000
0000000   0000000   000000000  0000000    000       000000000
     000  000       000   000  000   000  000       000   000
0000000   00000000  000   000  000   000   0000000  000   000
###

{ elem, empty, valid, reversed, matchr, stopEvent, str, $, _ } = require 'kxk'

log   = console.log
Input = require './input'

class Search extends Input

    constructor: () ->

        super 'search', '⚲'

    apply: (line) =>
        
        text = @input.value
        # log @name, text

        div   =$ '.log', line
        info  = line.info
        texts = text.trim().split /\s+/
        
        cfg = []
        for t in texts
            cfg.push [new RegExp(t), 'highlight']
            
        newLine = info.str
        rgs = matchr.ranges cfg, info.str 
        if valid rgs
            dss = matchr.dissect rgs
            # log '++', str dss
            for d in reversed dss
                span    = "<span class='highlight'>" + d.match + "</span>"
                newLine = newLine.slice(0, d.start) + span + newLine.slice(d.start + d.match.length)
                
        div.innerHTML = newLine
                
module.exports = Search
