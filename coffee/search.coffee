###
 0000000  00000000   0000000   00000000    0000000  000   000
000       000       000   000  000   000  000       000   000
0000000   0000000   000000000  0000000    000       000000000
     000  000       000   000  000   000  000       000   000
0000000   00000000  000   000  000   000   0000000  000   000
###

{ elem, stopEvent, _ } = require 'kxk'

log   = console.log
Input = require './input'

class Search extends Input

    constructor: () ->

        super 'search', '⚲'

    apply: (text, line) =>
        
        log @name, text, line.info

module.exports = Search
