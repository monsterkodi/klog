###
00000000  000  000      000000000  00000000  00000000 
000       000  000         000     000       000   000
000000    000  000         000     0000000   0000000  
000       000  000         000     000       000   000
000       000  0000000     000     00000000  000   000
###

{ empty, valid, elem, _ } = require 'kxk'

log = console.log
Input = require './input'

class Filter extends Input

    constructor: ->
        
        super 'filter', '⍛'
        
    apply: (text, line) =>
        
        text = text.trim()
        info = line.info
        # console.log @name, text, info
        hidden = valid(text) and info.str.indexOf(text) >= 0
        line.classList.toggle 'filtered', hidden
        
module.exports = Filter
