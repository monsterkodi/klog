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
        
        super 'find', '☉'
        @cfg = []
        if @input.value then @onInput()
        
    #  0000000  000   000  0000000    00     00  000  000000000  
    # 000       000   000  000   000  000   000  000     000     
    # 0000000   000   000  0000000    000000000  000     000     
    #      000  000   000  000   000  000 0 000  000     000     
    # 0000000    0000000   0000000    000   000  000     000     
    
    submit: (term) =>
        
        term = term.trim()
        return if empty term
        
        dir = prefs.get 'findDir', ''
        return if empty dir

        post.emit 'menuAction', 'Clear'
        
        log "find '#{term}' in #{dir}" # don't remove this log!
        
        @cp?.kill()
        args = [dir, term].concat window.filter.terms()
        @cp = childp.fork slash.join(__dirname, 'scanner.js'), args, stdio: ['pipe', 'pipe', 'ignore', 'ipc'], execPath: 'node'
        @cp.on 'message', @onScanner
        
    onScanner: (message) => 
    
        if message.type == 'find' 
            if @lastMessage.type == 'file' or @lastMessage.line < message.line-1
                window.lines.appendLog()
        else if message.type == 'file'
            window.lines.appendLog()
            
        @lastMessage = message
        window.lines.appendLog message
                
module.exports = Find
