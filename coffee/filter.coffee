###
00000000  000  000      000000000  00000000  00000000 
000       000  000         000     000       000   000
000000    000  000         000     0000000   0000000  
000       000  000         000     000       000   000
000       000  0000000     000     00000000  000   000
###

{ empty, valid, slash, log, $ } = require 'kxk'

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
            
    terms: -> 
        
        text = @input.value.trim()
        if valid text
            text.split /\s+/
        else
            []
        
    apply: (line) =>
        
        info    = line.info
        hidden  = false
        
        for t in @terms()
            
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
