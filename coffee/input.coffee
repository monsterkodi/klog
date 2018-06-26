###
000  000   000  00000000   000   000  000000000
000  0000  000  000   000  000   000     000   
000  000 0 000  00000000   000   000     000   
000  000  0000  000        000   000     000   
000  000   000  000         0000000      000   
###

{ elem, stopEvent, log, _ } = require 'kxk'

class Input

    constructor: (@name, text) ->

        @button = elem class:'winbutton gray', text:text, click:@onClick
        window.titlebar.pushElem @button
        
        @input = elem 'input', class:'input search', value:@name, dblclick:stopEvent
        @input.style.display = 'none'
        window.titlebar.pushElem @input

    onClick: =>
        
        if @input.style.display == 'none'
            @input.style.display = 'flex'
        else
            @input.style.display = 'none'
        
module.exports = Input
