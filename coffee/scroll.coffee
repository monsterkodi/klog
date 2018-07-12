###
 0000000   0000000  00000000    0000000   000      000      
000       000       000   000  000   000  000      000      
0000000   000       0000000    000   000  000      000      
     000  000       000   000  000   000  000      000      
0000000    0000000  000   000   0000000   0000000  0000000  
###

{ post, clamp, str } = require 'kxk'

log = console.log

class Scroll

    constructor: (@view, @lineHeight) ->

        @viewHeight = -1
        @init()
        
    # 000  000   000  000  000000000
    # 000  0000  000  000     000   
    # 000  000 0 000  000     000   
    # 000  000  0000  000     000   
    # 000  000   000  000     000   

    init: ->
        
        @scroll       =  0 # current scroll value from document start (pixels)
        @offsetTop    =  0 # height of view above first visible line (pixels)
        @offsetSmooth =  0 # smooth scrolling offset / part of top line that is hidden (pixels)
        
        @viewHeight   = -1
        @fullHeight   = -1 # total height of buffer (pixels)
        @fullLines    = -1 # number of full lines fitting in view (excluding partials)
        @viewLines    = -1 # number of lines fitting in view (including partials)
        @scrollMax    = -1 # maximum scroll offset (pixels)
        @numLines     = -1 # total number of lines in buffer
        @top          = -1 # index of first visible line in view
        @bot          = -1 # index of last  visible line in view
        
        log 'scroll.init', str @info()

    # 000  000   000  00000000   0000000 
    # 000  0000  000  000       000   000
    # 000  000 0 000  000000    000   000
    # 000  000  0000  000       000   000
    # 000  000   000  000        0000000 
    
    info: ->
        
        topbot: "#{@top} .. #{@bot} = #{@bot-@top} / #{@numLines} lines"
        scroll: "#{@scroll} offsetTop #{@offsetTop} viewHeight #{@viewHeight} scrollMax #{@scrollMax} fullLines #{@fullLines} viewLines #{@viewLines}"
        
    #  0000000   0000000   000       0000000  
    # 000       000   000  000      000       
    # 000       000000000  000      000       
    # 000       000   000  000      000       
    #  0000000  000   000  0000000   0000000  
    
    calc: ->
        
        if @viewHeight <= 0
            log "calc #{@viewHeight} <= 0"
            return
            
        @scrollMax   = Math.max(0,@fullHeight - @viewHeight)   # maximum scroll offset (pixels)
        @fullLines   = Math.floor(@viewHeight / @lineHeight)   # number of lines in view (excluding partials)
        @viewLines   = Math.ceil(@viewHeight / @lineHeight)+1  # number of lines in view (including partials)
        
        @by 0
        post.emit 'scroll', @scroll, @
        
    # 0000000    000   000
    # 000   000   000 000 
    # 0000000      00000  
    # 000   000     000   
    # 0000000       000   
        
    to: (p) => @by p-@scroll
    
    by: (delta, x) =>
        
        return if @viewLines < 0
        
        @view.scrollLeft += x if x
        
        # return if not delta and @top < @bot
        
        scroll = @scroll
        delta = 0 if Number.isNaN delta
        @scroll = parseInt clamp 0, @scrollMax, @scroll+delta
        top = parseInt @scroll / @lineHeight
        @offsetSmooth = @scroll - top * @lineHeight 
        
        @setTop top

        offset = 0
        offset += @offsetSmooth
        offset += (top - @top) * @lineHeight
        
        if offset != @offsetTop or scroll != @scroll
                        
            @offsetTop = parseInt offset
            @updateOffset()
            post.emit 'scroll', @scroll, @
            
    #  0000000  00000000  000000000  000000000   0000000   00000000 
    # 000       000          000        000     000   000  000   000
    # 0000000   0000000      000        000     000   000  00000000 
    #      000  000          000        000     000   000  000      
    # 0000000   00000000     000        000      0000000   000      
            
    setTop: (top) =>
        
        oldTop = @top
        oldBot = @bot
        
        @bot = Math.min top+@viewLines, @numLines-1
        @top = Math.max 0, @bot - @viewLines

        return if oldTop == @top and oldBot == @bot
        
        log 'setTop', oldTop, oldBot, '->', @top, @bot
            
        if (@top > oldBot) or (@bot < oldTop) or (oldBot < oldTop) 
            # new range outside, start from scratch
            num = @bot - @top + 1
            
            if num > 0 
                post.emit 'showLines', @top, @bot, num

        else   
            
            num = @top - oldTop
            
            if 0 < Math.abs num
                post.emit 'shiftLines', @top, @bot, num
                
    lineIndexIsInView: (li) -> @top <= li <= @bot
    
    # 00000000   00000000   0000000  00000000  000000000
    # 000   000  000       000       000          000   
    # 0000000    0000000   0000000   0000000      000   
    # 000   000  000            000  000          000   
    # 000   000  00000000  0000000   00000000     000   
    
    reset: =>
        
        @scroll       =  0 # current scroll value from document start (pixels)
        @offsetTop    =  0 # height of view above first visible line (pixels)
        @offsetSmooth =  0 # smooth scrolling offset / part of top line that is hidden (pixels)
        
        @numLines     =  0 # total number of lines in buffer
        @top          = -1 # index of first visible line in view
        @bot          = -1 # index of last  visible line in view
        
        post.emit 'clearLines'
        
        @updateOffset()
        
    # 000   000  000  00000000  000   000  000   000  00000000  000   0000000   000   000  000000000
    # 000   000  000  000       000 0 000  000   000  000       000  000        000   000     000   
    #  000 000   000  0000000   000000000  000000000  0000000   000  000  0000  000000000     000   
    #    000     000  000       000   000  000   000  000       000  000   000  000   000     000   
    #     0      000  00000000  00     00  000   000  00000000  000   0000000   000   000     000   

    setViewHeight: (h) =>
        
        if @viewHeight != h
            @viewHeight = h
            @calc()
            
    # 000   000  000   000  00     00  000      000  000   000  00000000   0000000
    # 0000  000  000   000  000   000  000      000  0000  000  000       000     
    # 000 0 000  000   000  000000000  000      000  000 0 000  0000000   0000000 
    # 000  0000  000   000  000 0 000  000      000  000  0000  000            000
    # 000   000   0000000   000   000  0000000  000  000   000  00000000  0000000 
        
    setNumLines: (n) =>
        
        if @numLines != n
            @fullHeight = n * @lineHeight
            if n
                @numLines = n
                @calc()
            else
                @reset()

    # 000      000  000   000  00000000  000   000  00000000  000   0000000   000   000  000000000
    # 000      000  0000  000  000       000   000  000       000  000        000   000     000   
    # 000      000  000 0 000  0000000   000000000  0000000   000  000  0000  000000000     000   
    # 000      000  000  0000  000       000   000  000       000  000   000  000   000     000   
    # 0000000  000  000   000  00000000  000   000  00000000  000   0000000   000   000     000   

    setLineHeight: (h) =>
            
        if @lineHeight != h
            @lineHeight = h
            @fullHeight = @numLines * @lineHeight
            @calc()

    #  0000000   00000000  00000000   0000000  00000000  000000000  
    # 000   000  000       000       000       000          000     
    # 000   000  000000    000000    0000000   0000000      000     
    # 000   000  000       000            000  000          000     
    #  0000000   000       000       0000000   00000000     000     
    
    updateOffset: -> 
           
        log 'updateOffset', @scroll, @offsetTop
        @view.style.transform = "translate3d(0,-#{@offsetTop}px, 0)"
        # @view.style.transform = "translate3d(0,-#{@scroll}px, 0)"
                    
module.exports = Scroll
