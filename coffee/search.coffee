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
        @cfg = []
        if @input.value then @onInput()
                        
module.exports = Search
