###
00000000  000  000      000000000  00000000  00000000 
000       000  000         000     000       000   000
000000    000  000         000     0000000   0000000  
000       000  000         000     000       000   000
000       000  0000000     000     00000000  000   000
###

{ elem, log, _ } = require 'kxk'

Input = require './input'

class Filter extends Input

    constructor: ->
        
        super 'filter', '⍛'
        
    onClick: =>
        
        log 'filter'
        
        super()

module.exports = Filter
