###
000000000  00000000  00000000   00     00   0000000  
   000     000       000   000  000   000  000       
   000     0000000   0000000    000000000  0000000   
   000     000       000   000  000 0 000       000  
   000     00000000  000   000  000   000  0000000   
###

{ elem, post, prefs, valid } = require 'kxk'

Term = require './term'

class Terms

    @: (@name, html) ->
        
        @button = elem class:'winbutton gray' html:html, click:@onButton
        @div    = elem class:'terms'
        @div.style.display = 'none'
        
        window.titlebar.pushElem @button
        window.titlebar.pushElem @div
        
        @terms = []
        @addTerm()
                        
        @show() if prefs.get "terms▸#{@name}▸visible"
        
        post.on 'focus' @onFocus
        
    addTerm: ->
        
        @terms.push new Term @
        
    delTerm: (term) ->
        
        @terms.splice @terms.indexOf(term), 1
        term.del()
        
    text: -> @terms[0].input.value # fix me!
    
    texts: -> @terms.map((t) -> t.input.value).filter (t) -> valid t
        
    onFocus: (name) => 
        
        if name == @name 
            @show()
            @terms[0].focus()
                     
    #  0000000  000   000   0000000   000   000  
    # 000       000   000  000   000  000 0 000  
    # 0000000   000000000  000   000  000000000  
    #      000  000   000  000   000  000   000  
    # 0000000   000   000   0000000   00     00  
    
    show: -> 

        prefs.set "terms▸#{@name}▸visible" true
        if @div.style.display == 'none'
            @div.style.display = 'flex'
            
    hide: ->
        
        prefs.set "terms▸#{@name}▸visible" false
        @div.style.display = 'none'
            
    onButton: (event) =>
        
        if @div.style.display == 'none' then @show() else @hide()
        
module.exports = Terms
