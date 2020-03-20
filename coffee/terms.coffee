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
        
        if prefTerms = prefs.get "terms▸#{@name}▸texts"
            for t in prefTerms
                @terms[-1]?.hideAddButton()
                @addTerm().input.value = t
        else
            @addTerm()
                              
        @show() if prefs.get "terms▸#{@name}▸visible"
        
        post.on 'focus' @onFocus
        post.on 'terms' @onTerms
        
    addTerm: ->
        
        term = new Term @
        term.showAddButton()
        @terms.push term
        term
        
    delTerm: (term) ->
        
        @terms.splice @terms.indexOf(term), 1
        term.del()
        @terms[-1].showAddButton()
        @store()
            
    texts: -> @terms.map((t) -> t.input.value).filter (t) -> valid t
        
    onFocus: (name) =>
        
        if name == @name 
            @show()
            @terms[0].focus()            
          
    onTerms: (name) => if name == @name then @store()
            
    store: -> prefs.set "terms▸#{@name}▸texts" @texts()
            
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
