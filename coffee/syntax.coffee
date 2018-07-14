###
 0000000  000   000  000   000  000000000   0000000   000   000
000        000 000   0000  000     000     000   000   000 000 
0000000     00000    000 0 000     000     000000000    00000  
     000     000     000  0000     000     000   000   000 000 
0000000      000     000   000     000     000   000  000   000
###

{ str, _ } = require 'kxk'

log = console.log

class Syntax

    @ranges: (string) ->
        
        rgs = []
        index = 0
        for char in string
            switch char 
                when '~', '@', '#', '/', '\\', ':', '.', ';', ',', '{', '}', '(', ')', '[', ']', '|', "'", '"', '`'
                    rgs.push
                        start: index
                        match: char
                        value: 'punctuation'
            index++
        log 'Syntax', str rgs
        rgs

module.exports = Syntax
