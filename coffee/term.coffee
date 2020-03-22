###
000000000  00000000  00000000   00     00
   000     000       000   000  000   000
   000     0000000   0000000    000000000
   000     000       000   000  000 0 000
   000     00000000  000   000  000   000
###

{ elem, empty, keyinfo, post, stopEvent } = require 'kxk'

class Term

    @: (@terms) ->

        @name = @terms.name
        @input = elem 'input' class:"input #{@name}" value:'' dblclick:stopEvent, click:stopEvent, parent:@terms.div
        @input.addEventListener 'change'  @onEnter
        @input.addEventListener 'input'   @onInput
        @input.addEventListener 'keydown' @onInputKey
        @input.focus()
           
        @showDelButton()
        
    # 0000000    000   000  000000000  000000000   0000000   000   000  
    # 000   000  000   000     000        000     000   000  0000  000  
    # 0000000    000   000     000        000     000   000  000 0 000  
    # 000   000  000   000     000        000     000   000  000  0000  
    # 0000000     0000000      000        000      0000000   000   000  
    
    showDelButton: ->
        
        if not @delButton
            @delButton = elem class:'termbutton' click:@onDel, dblclick:stopEvent, parent:@terms.div, html:"""
                <svg width="100%" height="100%" viewBox="0 0 30 30" stroke-linecap="round">
                    <line x1="8"  y1="8"  x2="22"  y2="22"></line>
                    <line x1="8"  y1="22"  x2="22"  y2="8"></line>
                </svg>
            """
        
    showAddButton: ->
        
        if not @addButton
            @addButton = elem class:'termbutton' click:@onAdd, dblclick:stopEvent, parent:@terms.div, html:"""
                <svg width="100%" height="100%" viewBox="0 0 30 30" stroke-linecap="round">
                    <line x1="15"  y1="6"  x2="15"  y2="24"></line>
                    <line x1="6"  y1="15"  x2="24"  y2="15"></line>
                </svg>
            """

    hideAddButton: ->
        
        @addButton.remove()
        delete @addButton
        
    emitHighlight: ->
        if @name in ['find' 'search']
            post.emit 'highlight' @name
        
    del: ->
        
        @input.remove()
        @delButton?.remove()
        @addButton?.remove()
        @emitHighlight()        
        post.emit 'focus' @name
        
    onDel: => 
        
        if @terms.terms.length > 1
            @terms.delTerm @
        else
            @input.value = ''
            @emitHighlight()
            @terms.store()
            
    onAdd: => 
        
        @hideAddButton()
        @terms.addTerm()

    focus: -> @input.focus()
                
    # 000  000   000  00000000   000   000  000000000  
    # 000  0000  000  000   000  000   000     000     
    # 000  000 0 000  00000000   000   000     000     
    # 000  000  0000  000        000   000     000     
    # 000  000   000  000         0000000      000     
    
    onInputKey: (event) =>
        
        info = keyinfo.forEvent event

        if 0 > info.mod.indexOf 'ctrl'
            event.stopPropagation()
            
        switch info.combo
            when 'enter'      then @terms.submit? @input.value
            when 'esc'        then @input.blur()
            when 'ctrl+enter' then @onAdd()
            when 'delete'     then if empty @input.value then @onDel()
            # else
                # klog info
        
    onEnter: => @onInput()
    
    onInput: =>
        
        @emitHighlight()            
        post.emit 'terms' @name
        
module.exports = Term
