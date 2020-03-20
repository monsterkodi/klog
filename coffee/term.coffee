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
        
        @button = elem class:'termbutton' click:@onButton, dblclick:stopEvent, parent:@terms.div
        @addButton()
        
        # @input.value = prefs.get("terms▸#{@name}▸value") ? ''

    del: ->
        
        @input.remove()
        @button.remove()
        
        if @name in ['find' 'search']
            post.emit 'highlight' @name
        
        post.emit 'focus' @name
        
    # 0000000    000   000  000000000  000000000   0000000   000   000  
    # 000   000  000   000     000        000     000   000  0000  000  
    # 0000000    000   000     000        000     000   000  000 0 000  
    # 000   000  000   000     000        000     000   000  000  0000  
    # 0000000     0000000      000        000      0000000   000   000  
    
    onButton: => 
        if @action == 'del'
            @terms.delTerm @
        else
            @delButton()
            @terms.addTerm()
        
    addButton: ->
        
        @action = 'add'
        @button.innerHTML = """
            <svg width="100%" height="100%" viewBox="0 0 30 30" stroke-linecap="round">
                <line x1="15"  y1="6"  x2="15"  y2="24"></line>
                <line x1="6"  y1="15"  x2="24"  y2="15"></line>
            </svg>
        """
    
    delButton: ->
        
        @action = 'del'
        @button.innerHTML = """
            <svg width="100%" height="100%" viewBox="0 0 30 30" stroke-linecap="round">
                <line x1="8"  y1="8"  x2="22"  y2="22"></line>
                <line x1="8"  y1="22"  x2="22"  y2="8"></line>
            </svg>
        """
        
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
            when 'enter' then @terms.submit? @input.value
            when 'esc'   then @input.blur()
            when 'delete'
                if @action == 'del' and empty @input.value
                    @terms.delTerm @
            when 'ctrl+enter'
                @delButton()
                @terms.addTerm()
            # else
                # klog info
        
    onEnter: => @onInput()
    
    onInput: =>
        
        if @name in ['find' 'search']
            post.emit 'highlight' @name
        
        # prefs.set "terms▸#{@name}▸value" @input.value
        
module.exports = Term
