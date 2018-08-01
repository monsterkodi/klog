###
 0000000  000  0000000  00000000  00000000 
000       000     000   000       000   000
0000000   000    000    0000000   0000000  
     000  000   000     000       000   000
0000000   000  0000000  00000000  000   000
###

{ setStyle, getStyle, prefs, elem, drag, log, $ } = require 'kxk'

class Sizer

    constructor: ->
        
        @initialized = false
        @sizer =$ '#sizer'
        @columns = {}
        
    init: ->
        
        @initialized = true
        for column in ['id-column', 'file-column']
            @columns[column] = elem class:"sizer-handle #{column}"
            @sizer.appendChild @columns[column]
            new drag
                target:  @columns[column]
                onStart: @onStart
                onMove:  @onMove
                onStop:  @onStop
        @updatePositions()
        
    onStart: (drag, event) =>        
        
        @dragColumn = event.target.className.split(' ')[1]
        
    onMove: (drag, event) =>
        
        return if not window.lines.lines.firstChild
        
        xoff = drag.lastPos.x
        @columns[@dragColumn].style.transform = "translateX(#{xoff}px)"
        
        div =$ ".#{@dragColumn}", window.lines.lines.firstChild
        
        visible = @isVisible @dragColumn
        @show @dragColumn
        left    = div.getBoundingClientRect().left
        width   = xoff - left + 10
        @hide(@dragColumn) if not visible

        if width < 10
            if visible
                @hide @dragColumn
        else
            if width > 20
                if not visible
                    @show @dragColumn
                setStyle "#lines div span.#{@dragColumn}", 'flex', "0 0 #{width}px"
        
    onStop: (drag, event) =>
        
        delete @dragColumn
        @updatePositions()
       
    columnKey: (column) -> "#lines div span.#{column}"
    isVisible: (column) -> 'none' != getStyle @columnKey(column), 'display'
        
    toggleDisplay: (column) ->
        
        if @isVisible column
            @hide column
        else
            @show column
        @updatePositions()

    hide: (column) ->
        
        prefs.set "display:#{column}", false
        setStyle @columnKey(column), 'display', 'none'
    
    show: (column) ->
        
        prefs.set "display:#{column}", true
        setStyle @columnKey(column), 'display', 'inline-block'
        # @updatePositions()
        
    updatePositions: ->

        return if not @initialized
        return if not window.lines.lines.firstChild
        wsum = 0
        for column in ['num-column', 'time-column', 'icon-column', 'id-column', 'file-column']
            div =$ ".#{column}", window.lines.lines.firstChild
            width = div.clientWidth
            wsum += width
            if width
                xoff = wsum 
            else
                xoff = 0
            if column in ['id-column', 'file-column']
                @columns[column].style.transform = "translateX(#{xoff}px)"
        
module.exports = Sizer
