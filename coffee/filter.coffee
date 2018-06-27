###
00000000  000  000      000000000  00000000  00000000 
000       000  000         000     000       000   000
000000    000  000         000     0000000   0000000  
000       000  000         000     000       000   000
000       000  0000000     000     00000000  000   000
###

{ empty, valid, elem, _ } = require 'kxk'

log = console.log
Input = require './input'

class Filter extends Input

    constructor: ->
        
        super 'filter', '⍛'
        
    apply: (line) =>
        
        text = @input.value
        info = line.info
        texts = text.trim().split /\s+/
        hidden = false
        
        for t in texts
            
            if valid(t) and info.str.indexOf(t) >= 0
                hidden = true
                break
                
        line.classList.toggle 'filtered', hidden
        
module.exports = Filter
