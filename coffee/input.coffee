###
000  000   000  00000000   000   000  000000000
000  0000  000  000   000  000   000     000   
000  000 0 000  00000000   000   000     000   
000  000  0000  000        000   000     000   
000  000   000  000         0000000      000   
###

{ post, keyinfo, prefs, stopEvent, elem, _ } = require 'kxk'

Highlight = require './highlight'

class Input

    constructor: (@name, html) ->
        
        @button = elem class:'winbutton gray', html:html, click:@onButton
        window.titlebar.pushElem @button
        
        @input = elem 'input', class:"input #{@name}", value:'', dblclick:stopEvent, autofocus:true, click:stopEvent
        @input.style.display = 'none'
        @input.addEventListener 'change',  @onEnter
        @input.addEventListener 'input',   @onInput
        @input.addEventListener 'keydown', @onInputKey
        window.titlebar.pushElem @input
        
        @input.value = prefs.get("input:#{@name}:value") ? ''
        
        @show() if prefs.get "input:#{@name}:visible"
        
        post.on 'focus', @onFocus
        
    text: -> @input.value
        
    onFocus: (name) => 
        if name == @name 
            @show()
     
    onInputKey: (event) =>
        
        info = keyinfo.forEvent event
        if 0 > info.mod.indexOf 'ctrl'
            event.stopPropagation()
        if info.combo == 'enter'
            @submit? @input.value
        if info.combo == 'esc'
            @input.blur()
        
    onEnter: => @onInput() 
        
    # 000  000   000  00000000   000   000  000000000  
    # 000  0000  000  000   000  000   000     000     
    # 000  000 0 000  00000000   000   000     000     
    # 000  000  0000  000        000   000     000     
    # 000  000   000  000         0000000      000     
    
    onInput: => 
        
        prefs.set "input:#{@name}:value", @input.value
        
        if @cfg?
            text = @input.value.trim()
            if text.startsWith('"') and text.endsWith('"')
                texts = [_.trim text, '"']
            else if text.startsWith("'") and text.endsWith("'")
                texts = [_.trim text, "'"]
            else
                texts = text.split(/\s+/).map (s) -> s.trim()
            
            @cfg = []
            for t in texts
                @cfg.push [new RegExp(_.escapeRegExp t), "highlight-#{@name}"]
  
            Highlight.lines()
        
    #  0000000  000   000   0000000   000   000  
    # 000       000   000  000   000  000 0 000  
    # 0000000   000000000  000   000  000000000  
    #      000  000   000  000   000  000   000  
    # 0000000   000   000   0000000   00     00  
    
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
