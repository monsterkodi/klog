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
        
        svg = """
            <svg width="100%" height="100%" viewBox="-0 -8 20 30">
                <line x1="0"  y1="0"  x2="8" y2="10"></line>
                <line x1="8"  y1="10" x2="8" y2="15"></line>
                <line x1="8"  y1="15" x2="12" y2="15"></line>
                <line x1="12" y1="15" x2="12" y2="10"></line>
                <line x1="12" y1="10" x2="20" y2="0"></line>
                <line x1="20" y1="0"  x2="0"  y2="0"></line>
            </svg>
        """
        super 'filter', svg #'⍛'
        
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
