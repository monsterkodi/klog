###
00000000  000  000   000  0000000    
000       000  0000  000  000   000  
000000    000  000 0 000  000   000  
000       000  000  0000  000   000  
000       000  000   000  0000000    
###

{ post, childp, matchr, empty, prefs, slash, valid, last, str, log, $ } = require 'kxk'

Input = require './input'

class Find extends Input

    constructor: ->
        
        svg = """
            <svg width="100%" height="100%" viewBox="0 0 20 20">
                <circle cx="10" cy="10" r="5" fill-opacity=0 />
            </svg>
        """
        
        super 'find', svg # '☉'
        @cfg = []
        if @input.value then @onInput()
        
    #  0000000  000   000  0000000    00     00  000  000000000  
    # 000       000   000  000   000  000   000  000     000     
    # 0000000   000   000  0000000    000000000  000     000     
    #      000  000   000  000   000  000 0 000  000     000     
    # 0000000    0000000   0000000    000   000  000     000     
    
    submit: (term) =>
        
        term ?= @text()
        term = term.trim()
        return if empty term
        
        dir = prefs.get 'findDir', ''
        return if empty dir

        post.emit 'menuAction', 'Clear'
        
        log "find '#{term}' in '#{dir}' using filter '#{window.filter.findPattern()}'" # don't remove this log!
        
        @cp?.kill()
        args = [dir, term].concat window.filter.terms()
        @cp = childp.fork slash.join(__dirname, 'scanner.js'), args, stdio: ['pipe', 'pipe', 'ignore', 'ipc'], execPath: 'node'
        @cp.on 'message', @onScanner
     
    onScanner: (message) => 
    
        if not window.filter.shouldLog message
            return
        
        if message.sep == '⯅'
            window.lines.appendLog()
        else if message.type == 'find' 
            if @lastMessage?.type == 'file' or @lastMessage.line < message.line-1
                window.lines.appendLog()
        else if message.type == 'file'
            if @lastMessage?.type != 'file'
                window.lines.appendLog()
            
        @lastMessage = message        
        window.lines.appendLog message
                
module.exports = Find
