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
            <svg width="100%" height="100%" viewBox="0 0 20 20">
                <circle cx="12" cy="9" r="4.5" fill-opacity=0 />
                <line x1="5" y1="16"  x2="8"  y2="13" stroke-width="1.5" stroke-linecap="round"></line>
            </svg>
        """
        
        super 'search', svg # '⚲'
        
        @cfg = []
        if @input.value then @onInput()
                        
module.exports = Search
