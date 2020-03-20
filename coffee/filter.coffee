###
00000000  000  000      000000000  00000000  00000000 
000       000  000         000     000       000   000
000000    000  000         000     0000000   0000000  
000       000  000         000     000       000   000
000       000  0000000     000     00000000  000   000
###

{ empty, slash, valid } = require 'kxk'

Input = require './input'

class Filter extends Input

    @: ->
        
        svg = """
            <svg width="100%" height="100%" viewBox="0 0 30 30">
                <line x1="4"  y1="7"  x2="13" y2="18" stroke-linecap="round"></line>
                <line x1="13" y1="18" x2="13" y2="23" stroke-linecap="round"></line>
                <line x1="13" y1="23" x2="18" y2="23" stroke-linecap="round"></line>
                <line x1="18" y1="23" x2="18" y2="18" stroke-linecap="round"></line>
                <line x1="18" y1="18" x2="27" y2="7"  stroke-linecap="round"></line>
                <line x1="27" y1="7"  x2="4"  y2="7"  stroke-linecap="round"></line>
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
