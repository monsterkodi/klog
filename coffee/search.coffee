###
 0000000  00000000   0000000   00000000    0000000  000   000
000       000       000   000  000   000  000       000   000
0000000   0000000   000000000  0000000    000       000000000
     000  000       000   000  000   000  000       000   000
0000000   00000000  000   000  000   000   0000000  000   000
###

{ valid, reversed, matchr, str, $ } = require 'kxk'

log   = console.log
Input = require './input'

class Search extends Input

    constructor: () ->

        super 'search', '⚲'

    apply: (line) =>
        
        info  = line.info
        
        return if info.id in ['file', 'find']
        
        text = @input.value

        div   =$ '.log', line
        texts = text.trim().split(/\s+/).map (s) -> s.trim()
        
        cfg = []
        for t in texts
            cfg.push [new RegExp(t), 'highlight']
            
        lines = []
        for line in info.str.split '\n'
            rgs = matchr.ranges cfg, line
            if valid rgs
                dss = matchr.dissect rgs
                for d in reversed dss
                    span = "<span class='highlight'>" + str.encode(d.match) + "</span>"
                    line = line.slice(0, d.start) + span + line.slice(d.start + d.match.length)
            lines.push line
        
        div.innerHTML = lines.join '<br>'
                
module.exports = Search
