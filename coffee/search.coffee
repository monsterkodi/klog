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

        svg = """
            <svg width="100%" height="100%" viewBox="0 0 30 30" stroke-linecap="round">
                <line x1="4"  y1="23"  x2="26"  y2="23"></line>
                <line x1="4"  y1="23"  x2="15"  y2="7"></line>
                <line x1="26" y1="23"  x2="15"  y2="7"></line>
            </svg>
        """
        
        super 'search', svg
        
        @cfg = []
        if @input.value then @onInput()
                        
module.exports = Search
