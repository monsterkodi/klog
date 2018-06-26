###
 0000000  00000000   0000000   00000000    0000000  000   000
000       000       000   000  000   000  000       000   000
0000000   0000000   000000000  0000000    000       000000000
     000  000       000   000  000   000  000       000   000
0000000   00000000  000   000  000   000   0000000  000   000
###

{ elem, stopEvent, log, _ } = require 'kxk'

Input = require './input'

class Search extends Input

    constructor: () ->

        super 'search', '⚲'

    onClick: =>
        
        log 'search'

        super()
        
module.exports = Search
