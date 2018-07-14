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
            
            if word in ['console','process','global','module','exports','fs','os']
                obj.rgs.push
                    start: obj.index - word.length - 1
                    match: word
                    value: 'module'
    
    @ranges: (string) ->
        
        obj =
            rgs:    []
            words:  []
            word:   ''
            index:  0
        
        for char in string
            
            switch char 
                when '~', '@', '#', '/', '\\', ':', '.', ';', ',', '{', '}', '(', ')', '[', ']', '|', "'", '"', '`'
                    obj.rgs.push
                        start: obj.index
                        match: char
                        value: 'punctuation'
                when '+'
                    Syntax.endWord obj
                when ' '
                    Syntax.endWord obj
                else
                    obj.word += char
                    
            obj.index++
            
        Syntax.endWord obj
            
        log 'Syntax', str obj
        
        obj.rgs

module.exports = Syntax
