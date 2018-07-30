###
 0000000  00000000   0000000   00000000    0000000  000   000
000       000       000   000  000   000  000       000   000
0000000   0000000   000000000  0000000    000       000000000
     000  000       000   000  000   000  000       000   000
0000000   00000000  000   000  000   000   0000000  000   000
###

{ post, empty } = require 'kxk'

log   = console.log
Input = require './input'

class Search extends Input

    constructor: () ->

        svg = """
            <svg width="100%" height="100%" viewBox="0 0 30 30" stroke-linecap="round">
                <line x1="4"  y1="23"  x2="26"  y2="23"></line>
                <line x1="4"  y1="23"  x2="15"  y2="7"></line>
                <line x1="26" y1="23"  x2="15"  y2="7"></line>
            </svg>
        """
        
        super 'search', svg

        @searchIndex = -1
        @searchTerm = ''
        
        @cfg = []
        if @input.value then @onInput()
          
    submit: (term, maxIndex=-1) =>
        
        if empty term
            @searchIndex = -1
            return
            
        if term != @searchTerm
            @searchTerm = term
            @searchIndex = -1
            
        if maxIndex < 0
            maxIndex = window.lines.cache.length-1
        else if maxIndex > window.lines.cache.length-1
            maxIndex = window.lines.cache.length-1
            
        if @searchIndex+1 <= maxIndex
            for index in [@searchIndex+1..maxIndex]
                line = window.lines.cache[index]
                if line.info.type != 'file' and 0 <= line.info.str.indexOf term
                    @searchIndex = index
                    post.emit 'selectLine', @searchIndex
                    return
                
        if @searchIndex > 0
            maxIndex = @searchIndex-1
            @searchIndex = -1
            @submit term, maxIndex
        
module.exports = Search
