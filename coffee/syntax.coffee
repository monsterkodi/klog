###
 0000000  000   000  000   000  000000000   0000000   000   000
000        000 000   0000  000     000     000   000   000 000 
0000000     00000    000 0 000     000     000000000    00000  
     000     000     000  0000     000     000   000   000 000 
0000000      000     000   000     000     000   000  000   000
###

{ valid, str, log } = require 'kxk'

log = console.log

class Syntax

    @endWord: (obj) ->
        
        if valid obj.word
            
            word = obj.word
            
            obj.words.push word
            obj.word = ''
            
            clss = switch word
                when 'first', 'last', 'valid', 'empty', 'clamp', 'watch', 'str', 'pos', 'elem', 'stopEvent', 'if', 'else', 'then', 'for', 'of', 'in', 'is', 'while', 'do', 'unless', 'not', 'or', 'and', 'try', 'catch', 'return', 'break', 'continue', 'new', 'switch', 'when', 'super', 'extends', 'by'
                    'keyword'
                when 'post', 'childp', 'matchr', 'prefs', 'slash', 'noon', 'args', 'console','process','global','module','exports','fs','os'
                    'module'                    
                when 'log'
                    'function'
                when 'err', 'error'
                    'function call'
                when 'require'
                    'require'
                    
            if clss            
                obj.rgs.push
                    start: obj.index - word.length
                    match: word
                    value: clss
    
    @ranges: (string) ->
        
        obj =
            rgs:    []
            words:  []
            word:   ''
            index:  0
        
        for char in string
            
            wordEnd = true
            
            switch char
                
                when "'", '"', '`'
                    obj.rgs.push
                        start: obj.index
                        match: char
                        value: 'punctuation'
                when '~', '+', '-', '^', '=', '@', '#', '/', '\\', ':', '.', ';', ',', '|', '{', '}', '(', ')', '[', ']'
                    obj.rgs.push
                        start: obj.index
                        match: char
                        value: 'punctuation'
                when '+' then 
                when ' ' then 
                else
                    wordEnd = false
                    obj.word += char
                    
            if wordEnd then Syntax.endWord obj
                    
            obj.index++
            
        Syntax.endWord obj
            
        # log 'Syntax', str obj
        
        obj.rgs

module.exports = Syntax
