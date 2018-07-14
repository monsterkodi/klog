###
00000000  000  000      000000000  00000000  00000000 
000       000  000         000     000       000   000
000000    000  000         000     0000000   0000000  
000       000  000         000     000       000   000
000       000  0000000     000     00000000  000   000
###

{ slash, empty } = require 'kxk'

log   = console.log
Input = require './input'

class Filter extends Input

    constructor: ->
        
        super 'filter', '⍛'
        
    onInput: =>
        
        super()
        
        lines =$ '#lines'
        for line in lines.children
            @apply line
        
    apply: (line) =>
        
        text    = @input.value
        info    = line.info
        texts   = text.trim().split /\s+/
        hidden  = false
        
        for t in texts
            
            continue if empty t
            if t.startsWith('@') 
                if slash.base(info.source) == t.substr 1
                    hidden = true
                    break
            else if t.startsWith('#') 
                if info.id == t.substr 1
                    hidden = true
                    break
            else if t.startsWith('.') 
                if info.source and slash.ext(info.source) == t.substr 1
                    hidden = true
                    break
            else if info.str.indexOf(t) >= 0
                hidden = true
                break
                
        line.classList.toggle 'filtered', hidden
        
module.exports = Filter
