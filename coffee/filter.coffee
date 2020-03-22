###
00000000  000  000      000000000  00000000  00000000 
000       000  000         000     000       000   000
000000    000  000         000     0000000   0000000  
000       000  000         000     000       000   000
000       000  0000000     000     00000000  000   000
###

{ empty, slash } = require 'kxk'

Terms = require './terms'

class Filter extends Terms

    @: ->
        
        svg = """
            <svg width="100%" height="100%" viewBox="0 0 30 30">
                <line x1="4"  y1="7"  x2="13" y2="18" stroke-linecap="round"></line>
                <line x1="13" y1="18" x2="13" y2="23" stroke-linecap="round"></line>
                <line x1="13" y1="23" x2="18" y2="23" stroke-linecap="round"></line>
                <line x1="18" y1="23" x2="18" y2="18" stroke-linecap="round"></line>
                <line x1="18" y1="18" x2="27" y2="7"  stroke-linecap="round"></line>
                <line x1="27" y1="7"  x2="4"  y2="7"  stroke-linecap="round"></line>
            </svg>
        """
        super 'filter' svg
        
    findPattern: => @texts().filter (t) -> t[0] in ['.' '!']
            
    submit: (term) => if term[0] in ['.' '!'] then window.find.submit()
        
    shouldLog: (info) =>
         
        hidden = false
        positive = []
         
        for t in @texts()
             
            continue if empty t
            continue if t[0] in ['.' '!']
            if t[0] == '-'
                if t.startsWith('-@') 
                    if slash.base(info.source) == t.substr 2
                        hidden = true
                        break
                else if t.startsWith('-#') 
                    if info.id == t.substr 2
                        hidden = true
                        break
                else if info.str.indexOf(t.substr 1) >= 0
                    hidden = true
                    break
            else positive.push t
            
        return false if hidden
                
        if positive.length
            hidden = true
            for t in positive
                if t[0] == '@'
                    if slash.base(info.source) == t.substr 1
                        hidden = false
                        break
                else if t[0] == '#'
                    if info.id == t.substr 1
                        hidden = false
                        break
                else if info.str.indexOf(t) >= 0
                    hidden = false
                    break
                    
            return not hidden
        true
        
module.exports = Filter
