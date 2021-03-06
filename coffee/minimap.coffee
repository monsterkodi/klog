###
00     00  000  000   000  000  00     00   0000000   00000000
000   000  000  0000  000  000  000   000  000   000  000   000
000000000  000  000 0 000  000  000000000  000000000  00000000
000 0 000  000  000  0000  000  000 0 000  000   000  000
000   000  000  000   000  000  000   000  000   000  000
###

{ $, clamp, drag, elem, empty, getStyle, post } = require 'kxk'

MapScroll = require './mapscroll'
Highlight = require './highlight'

class Minimap

    @: (@editor) ->

        minimapWidth = parseInt getStyle '.minimap' 'width'

        @colors = {}
        @width  = 2*minimapWidth
        @height = 8192
        @offsetLeft = 6

        @elem    = elem class:'minimap' id:'minimap'
        @lines   = elem 'canvas' class:'minimapLines' width:@width, height:@height
        @topbot  = elem class:'topbot'

        @elem.appendChild @lines
        @elem.appendChild @topbot

        @elem.addEventListener 'wheel' @editor.scrollbar?.onWheel

        main =$ '#main'
        main.appendChild @elem
        
        post.on 'clearLines' @onEditorScroll
        post.on 'scroll'     @onEditorScroll

        @scroll = new MapScroll
            exposeMax:  @height/4
            lineHeight: 4
            viewHeight: 2*main.clientHeight

        @scroll.name = "minimap"

        @drag = new drag
            target:  @elem
            onStart: @onStart
            onMove:  @onDrag
            cursor: 'pointer'

        @scroll.on 'clearLines'  @clearAll
        @scroll.on 'scroll'      @onScroll
        @scroll.on 'exposeLines' @onExposeLines
        @scroll.on 'vanishLines' @onVanishLines
        @scroll.on 'exposeLine'  @exposeLine

        @onScroll()
        @drawLines()
        @drawTopBot()

    # 0000000    00000000    0000000   000   000
    # 000   000  000   000  000   000  000 0 000
    # 000   000  0000000    000000000  000000000
    # 000   000  000   000  000   000  000   000
    # 0000000    000   000  000   000  00     00

    drawLines: (top=@scroll.exposeTop, bot=@scroll.exposeBot) =>

        ctx = @lines.getContext '2d'
        y = parseInt((top-@scroll.exposeTop)*@scroll.lineHeight)
        ctx.clearRect 0, y, @width, ((bot-@scroll.exposeTop)-(top-@scroll.exposeTop)+1)*@scroll.lineHeight
        return if @scroll.exposeBot < 0

        bot = Math.min bot, @editor.cache.length-1
        return if bot < top

        for li in [top..bot]
            y = parseInt((li-@scroll.exposeTop)*@scroll.lineHeight)
            diss = @editor.cache[li].info.highlightDiss
            
            if empty(diss) and not empty @editor.cache[li].info.str
                Highlight.line @editor.cache[li]
                diss = @editor.cache[li].info.highlightDiss
                
            if diss?.length
                for r in diss
                    break if 2*r.start >= @width
                    if r.clss?
                        ctx.fillStyle = @colorForClassnames r.clss
                    else
                        ctx.fillStyle = @colorForStyle r.styl
                    ctx.fillRect @offsetLeft+2*r.start, y, 2*r.match.length, @scroll.lineHeight

    colorForClassnames: (clss) ->

        if not @colors[clss]?

            div = elem class: clss
            document.body.appendChild div
            computedStyle = window.getComputedStyle(div)
            color = computedStyle.color
            opacity = computedStyle.opacity
            if opacity != '1'
                color = 'rgba(' + color.slice(4, color.length-2) + ' ' + opacity + ')' 
            @colors[clss] = color
            div.remove()

        return @colors[clss]
              
    colorForStyle: (styl) ->

        if not @colors[styl]?
            div = elem 'div'
            div.style = styl
            document.body.appendChild div
            @colors[styl] = window.getComputedStyle(div).color
            div.remove()

        return @colors[styl]
        
    drawTopBot: =>

        return if @scroll.exposeBot < 0

        lh = @scroll.lineHeight/2
        th = (@editor.scroll.bot-@editor.scroll.top+1)*lh
        ty = 0
        if @editor.scroll.scrollMax
            ty = (Math.min(0.5*@scroll.viewHeight, @scroll.numLines*2)-th) * @editor.scroll.scroll / @editor.scroll.scrollMax
        @topbot.style.height = "#{th}px"
        @topbot.style.top    = "#{ty}px"

    # 00000000  000   000  00000000    0000000    0000000  00000000
    # 000        000 000   000   000  000   000  000       000
    # 0000000     00000    00000000   000   000  0000000   0000000
    # 000        000 000   000        000   000       000  000
    # 00000000  000   000  000         0000000   0000000   00000000

    exposeLine:   (li) => @drawLines li, li
    onExposeLines: (e) => @drawLines @scroll.exposeTop, @scroll.exposeBot

    onVanishLines: (e) =>
        if e.top?
            @drawLines @scroll.exposeTop, @scroll.exposeBot
        else
            @clearRange @scroll.exposeBot, @scroll.exposeBot+@scroll.numLines

    #  0000000  000   000   0000000   000   000   0000000   00000000
    # 000       000   000  000   000  0000  000  000        000
    # 000       000000000  000000000  000 0 000  000  0000  0000000
    # 000       000   000  000   000  000  0000  000   000  000
    #  0000000  000   000  000   000  000   000   0000000   00000000

    onChanged: (changeInfo) =>

        @drawSelections() if changeInfo.selects
        @drawCursors()    if changeInfo.cursors

        return if not changeInfo.changes.length

        @scroll.setNumLines @editor.numLines()

        for change in changeInfo.changes
            li = change.oldIndex
            break if not change.change in ['deleted' 'inserted']
            @drawLines li, li

        if li <= @scroll.exposeBot
            @drawLines li, @scroll.exposeBot

    # 00     00   0000000   000   000   0000000  00000000
    # 000   000  000   000  000   000  000       000
    # 000000000  000   000  000   000  0000000   0000000
    # 000 0 000  000   000  000   000       000  000
    # 000   000   0000000    0000000   0000000   00000000

    onDrag: (drag, event) =>

        if @scroll.fullHeight > @scroll.viewHeight
            br = @elem.getBoundingClientRect()
            ry = event.clientY - br.top
            pc = 2*ry / @scroll.viewHeight
            li = parseInt pc * @editor.scroll.numLines
            @jumpToLine li, event
        else
            @jumpToLine @lineIndexForEvent(event), event

    onStart: (drag,event) => 
    
        window.lines.scroll.wheel.accum = 0
        @jumpToLine @lineIndexForEvent(event), event

    jumpToLine: (li, event) ->

        @editor.scroll.to (li-5) * @editor.scroll.lineHeight
        @onEditorScroll()

    lineIndexForEvent: (event) ->

        st = @elem.scrollTop
        br = @elem.getBoundingClientRect()
        ly = clamp 0, @elem.offsetHeight, event.clientY - br.top
        py = parseInt(Math.floor(2*ly/@scroll.lineHeight)) + @scroll.top
        li = parseInt Math.min(@scroll.numLines-1, py)
        li

    #  0000000   0000000  00000000    0000000   000      000
    # 000       000       000   000  000   000  000      000
    # 0000000   000       0000000    000   000  000      000
    #      000  000       000   000  000   000  000      000
    # 0000000    0000000  000   000   0000000   0000000  0000000

    onEditorScroll: (scrollValue, editorScroll) =>

        editorScroll ?= @editor.scroll
        
        if @scroll.viewHeight != 2*editorScroll.viewHeight
            @scroll.setViewHeight 2*editorScroll.viewHeight
            @onScroll()
            
        if @scroll.numLines != editorScroll.numLines
            @scroll.setNumLines editorScroll.numLines    
        
        if @scroll.fullHeight > @scroll.viewHeight
            pc = editorScroll.scroll / editorScroll.scrollMax
            tp = parseInt pc * @scroll.scrollMax
            @scroll.to tp
            
        @drawTopBot()

    onScroll: =>

        y = parseInt -@height/4-@scroll.offsetTop/2
        x = parseInt @width/4
        t = "translate3d(#{x}px, #{y}px, 0px) scale3d(0.5, 0.5, 1)"

        @lines.style.transform   = t

    #  0000000  000      00000000   0000000   00000000
    # 000       000      000       000   000  000   000
    # 000       000      0000000   000000000  0000000
    # 000       000      000       000   000  000   000
    #  0000000  0000000  00000000  000   000  000   000

    clearRange: (top, bot) ->

        ctx = @lines.getContext '2d'
        ctx.clearRect 0, (top-@scroll.exposeTop)*@scroll.lineHeight, 2*@width, (bot-top)*@scroll.lineHeight

    clearAll: =>

        @topbot.width  = @topbot.width
        @lines.width   = @lines.width
        @topbot.style.height = '0'

module.exports = Minimap
