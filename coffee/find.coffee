###
00000000  000  000   000  0000000    
000       000  0000  000  000   000  
000000    000  000 0 000  000   000  
000       000  000  0000  000   000  
000       000  000   000  0000000    
###

{ _, args, childp, empty, filter, post, prefs, slash } = require 'kxk'

Terms = require './terms'

class Find extends Terms

    @: ->
        
        svg = """
            <svg width="100%" height="100%" viewBox="0 0 30 30">
                <circle cx="17" cy="13" r="7" fill-opacity=0 />
                <line x1="5" y1="23"  x2="11"  y2="18" stroke-linecap="round"></line>
            </svg>
        """
        
        super 'find' svg # '⚲'
        
        @cfg = []
        
    #  0000000  000   000  0000000    00     00  000  000000000  
    # 000       000   000  000   000  000   000  000     000     
    # 0000000   000   000  0000000    000000000  000     000     
    #      000  000   000  000   000  000 0 000  000     000     
    # 0000000    0000000   0000000    000   000  000     000     
    
    submit: =>
        
        dir = prefs.get 'findDir' ''
        return if empty dir

        post.emit 'menuAction' 'Clear'
        post.emit 'highlight' 'find'
        
        terms = @texts().map (t) -> new Buffer(t).toString 'base64'
        
        window.lines.appendLog 
            id:     'klog'
            file:   'find'            
            icon:   slash.fileUrl slash.join __dirname, '..' 'img' 'menu@2x.png'
            str:    "find \"#{@texts().join(',')}\" in #{dir}: using filter \"#{window.filter.findPattern()}\""
        
        @cp?.kill()
        args = [dir, window.filter.findPattern().join(','), terms]
        @cp = childp.fork slash.join(__dirname, 'scanner.js'), args
        @cp.on 'message' @onScanner
     
    onScanner: (message) => 
        
        if _.isString message
            # log "message: '#{message}'"
            message = JSON.parse message
        
        if not window.filter.shouldLog message
            return
        
        if message.sep == '▶'
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
