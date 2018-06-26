###
000  000   000  00000000   000   000  000000000
000  0000  000  000   000  000   000     000   
000  000 0 000  00000000   000   000     000   
000  000  0000  000        000   000     000   
000  000   000  000         0000000      000   
###

{ post, elem, keyinfo, stopEvent, log, $, _ } = require 'kxk'

class Input

    constructor: (@name, text) ->

        @button = elem class:'winbutton gray', text:text, click:@onButton
        window.titlebar.pushElem @button
        
        @input = elem 'input', class:'input search', value:'', dblclick:stopEvent, autofocus:true, click:stopEvent
        @input.style.display = 'none'
        @input.addEventListener 'change',  @onEnter
        @input.addEventListener 'input',   @onInput
        @input.addEventListener 'keydown', @onInputKey
        window.titlebar.pushElem @input
        
        post.on 'focus', @onFocus
        
    onFocus: (name) => 
        if name == @name 
            @show()
     
    onInputKey: (event) =>
        
        info = keyinfo.forEvent event
        if info.mod != 'ctrl'
            event.stopPropagation()
        if info.combo == 'esc'
            @input.blur()
        
    onEnter: => log 'Enter', @input.value
    onInput: => 
        lines =$ '#lines'
        for line in lines.children
            @apply @input.value, line
        
    show: -> 
        
        if @input.style.display == 'none'
            @input.style.display = 'flex'
        @input.focus()
            
    onButton: (event) =>
        
        if @input.style.display == 'none'
            @show()
        else
            @input.style.display = 'none'
        
module.exports = Input
