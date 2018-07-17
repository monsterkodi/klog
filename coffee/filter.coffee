###
00000000  000  000      000000000  00000000  00000000 
000       000  000         000     000       000   000
000000    000  000         000     0000000   0000000  
000       000  000         000     000       000   000
000       000  0000000     000     00000000  000   000
###

{ valid, empty, slash, str, log, $ } = require 'kxk'

log   = console.log
Input = require './input'

class Filter extends Input

    constructor: ->
        
        super 'filter', '⍛'
        
    terms: => 
        
        text = @input.value.trim()
        if valid text
            text.split /\s+/
        else
            []
          
    findPattern: =>
        
        @terms().filter (t) -> t[0] in ['.', '!']
            
    submit: =>
        
        window.find.submit()
        
    shouldLog: (info) =>
         
        hidden = false
         
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
            else if t[0] in ['.', '!']
                continue
            else if info.str.indexOf(t) >= 0
                hidden = true
                break
            
        not hidden
        
module.exports = Filter
