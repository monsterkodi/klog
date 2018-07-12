###
00000000  000  000   000  0000000    
000       000  0000  000  000   000  
000000    000  000 0 000  000   000  
000       000  000  0000  000   000  
000       000  000   000  0000000    
###

{ reversed, childp, matchr, empty, prefs, slash, valid, str, log, $ } = require 'kxk'

Input = require './input'

class Find extends Input

    constructor: ->
        
        super 'find', '☉'
        
    submit: (term) =>
        
        term = term.trim()
        return if empty term
        
        dir = prefs.get 'findDir', ''
        return if empty dir
        
        window.lines.appendLog id:'find', str:"find #{term} in #{dir}", find:term, type:'find'
        
        @cp?.kill()
        @cp = childp.fork slash.join(__dirname, 'scanner.js'), [dir, term], stdio: ['pipe', 'pipe', 'ignore', 'ipc'], execPath: 'node'
        @cp.on 'message', @onScanner
        
    onScanner: (message) => window.lines.appendLog message
        
    apply: (line) =>
        
        info = line.info
        
        return if info.id != 'find'
        
        text = info.find

        div   =$ '.log', line
        texts = text.trim().split(/\s+/).map (s) -> s.trim()
        
        cfg = []
        for t in texts
            cfg.push [new RegExp(t), 'highlight']
            
        lines = []
        for line in info.str.split '\n'
            rgs = matchr.ranges cfg, line
            if valid rgs
                dss = matchr.dissect rgs
                for d in reversed dss
                    span = "<span class='find'>" + str.encode(d.match) + "</span>"
                    line = line.slice(0, d.start) + span + line.slice(d.start + d.match.length)
            lines.push line
        
        div.innerHTML = lines.join '<br>'
        
module.exports = Find
