###
000  000   000  00000000   000   000  000000000
000  0000  000  000   000  000   000     000   
000  000 0 000  00000000   000   000     000   
000  000  0000  000        000   000     000   
000  000   000  000         0000000      000   
###

{ post, prefs, elem, keyinfo, stopEvent, log, $, _ } = require 'kxk'

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
        
        @input.value = prefs.get("input:#{@name}:value") ? ''
        @show() if prefs.get "input:#{@name}:visible"
        
        post.on 'focus', @onFocus
        
    onFocus: (name) => 
        if name == @name 
            @show()
     
    onInputKey: (event) =>
        
        info = keyinfo.forEvent event
        if 0 > info.mod.indexOf 'ctrl'
            event.stopPropagation()
        if info.combo == 'esc'
            @input.blur()
        
    onEnter: => @onInput() #log 'Enter', @input.value
    onInput: => 
        
        prefs.set "input:#{@name}:value", @input.value
        
        lines =$ '#lines'
        for line in lines.children
            @apply line
        
    show: -> 

        prefs.set "input:#{@name}:visible", true
        if @input.style.display == 'none'
            @input.style.display = 'flex'
        @input.focus()
            
    hide: ->
        
        prefs.set "input:#{@name}:visible", false
        @input.style.display = 'none'
            
    onButton: (event) =>
        
        if @input.style.display == 'none'
            @show()
        else
            @hide()
        
module.exports = Input
