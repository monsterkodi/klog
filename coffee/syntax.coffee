###
 0000000  000   000  000   000  000000000   0000000   000   000
000        000 000   0000  000     000     000   000   000 000 
0000000     00000    000 0 000     000     000000000    00000  
     000     000     000  0000     000     000   000   000 000 
0000000      000     000   000     000     000   000  000   000
###

{ valid, first, empty, last, str, log } = require 'kxk'

log = console.log

class Syntax

    @noComment      = ['txt', 'md']
    @hashComment    = ['coffee', 'sh', 'yml', 'yaml', 'noon']
    @noSlashComment = Syntax.noComment.concat Syntax.hashComment
    
    # 00000000    0000000   000   000   0000000   00000000   0000000  
    # 000   000  000   000  0000  000  000        000       000       
    # 0000000    000000000  000 0 000  000  0000  0000000   0000000   
    # 000   000  000   000  000  0000  000   000  000            000  
    # 000   000  000   000  000   000   0000000   00000000  0000000   
    
    @ranges: (string, ext) ->
        
        obj =
            ext:    ext ? 'txt' 
            rgs:    []   # list of ranges (result)
            words:  []   # encountered words
            stack:  []   # unclosed strings 
            word:   ''   # currently parsed word
            turd:   ''   # currently parsed stuff inbetween words 
            last:   ''   # the turd before the current/last-completed word
            index:  0    
        
        for char in string
            
            obj.char = char
            
            switch char
                
                when "'", '"', '`', '#'
                    
                    Syntax.endWord   obj
                    Syntax.doStack   obj
                    
                when '+', '-', '*', '<', '>', '=', '^', '~', '@', '$', '&', '%', '/', '\\', ':', '.', ';', ',', '!', '|', '{', '}', '(', ')', '[', ']'
                    
                    Syntax.endWord   obj
                    Syntax.doPunct   obj
                    Syntax.stackChar obj
                            
                when ' ', '\t' 
                    
                    Syntax.endWord   obj
                    Syntax.stackChar obj
                    
                else # continue the current word
                    
                    Syntax.endTurd   obj
                    Syntax.stackChar obj
                                        
            obj.index++
          
        obj.char = null
        Syntax.endWord    obj
        Syntax.endComment obj
            
        # log 'Syntax', str obj
        
        obj.rgs
    
    # 00000000  000   000  0000000    000   000   0000000   00000000   0000000    
    # 000       0000  000  000   000  000 0 000  000   000  000   000  000   000  
    # 0000000   000 0 000  000   000  000000000  000   000  0000000    000   000  
    # 000       000  0000  000   000  000   000  000   000  000   000  000   000  
    # 00000000  000   000  0000000    00     00   0000000   000   000  0000000    
    
    @endWord: (obj) ->
        
        obj.turd += obj.char # use = here?
        
        char = obj.char
        
        if valid obj.word
            
            word = obj.word
            
            obj.words.push word
            obj.word = ''

            getValue = (back=-1)     -> obj.rgs[obj.rgs.length+back]?.value 
            setValue = (back, value) -> obj.rgs[obj.rgs.length+back]?.value = value
            setClass = (clss) ->
                obj.rgs.push
                    start: obj.index - word.length
                    match: word
                    value: clss
                null
            
            switch obj.ext 
                
                #  0000000   0000000   00000000  00000000  00000000  00000000  
                # 000       000   000  000       000       000       000       
                # 000       000   000  000000    000000    0000000   0000000   
                # 000       000   000  000       000       000       000       
                #  0000000   0000000   000       000       00000000  00000000  
                
                when 'js', 'coffee'
                    
                    switch word
                        when 'first', 'last', 'valid', 'empty', 'clamp', 'watch', 'str', 'pos', 'elem', 'stopEvent', 'if', 'else', 'then', 'for', 'of', 'in', 'is', 'while', 'do', 'unless', 'not', 'or', 'and', 'try', 'catch', 'return', 'break', 'continue', 'new', 'switch', 'when', 'super', 'extends', 'by', 'true', '__dirname', '__filename'
                            return setClass 'keyword'
                        when 'post', 'childp', 'matchr', 'prefs', 'slash', 'noon', 'args', 'console','process','global','module','exports','fs','os'
                            return setClass 'module'                    
                        when 'log'
                            return setClass 'function'
                        when 'err', 'error'
                            return setClass 'function call'
                        when 'undefined', 'null', 'false'
                            return setClass 'nil'
                        when 'require'
                            return setClass 'require'
                    
            # 000   000  000   000  00     00  0000000    00000000  00000000   
            # 0000  000  000   000  000   000  000   000  000       000   000  
            # 000 0 000  000   000  000000000  0000000    0000000   0000000    
            # 000  0000  000   000  000 0 000  000   000  000       000   000  
            # 000   000   0000000   000   000  0000000    00000000  000   000  
            
            if /^\d+$/.test word
                
                if obj.last == '.'                        
                    
                    if getValue(-4) == 'number float' and getValue(-2) == 'number float'
                        setValue -4, 'semver'
                        setValue -3, 'semver punctuation'
                        setValue -2, 'semver'
                        setValue -1, 'semver punctuation'
                        return setClass 'semver'
                            
                    if getValue(-2) == 'number'
                        setValue -2, 'number float'
                        setValue -1, 'number float punctuation'
                        return setClass 'number float'
                        
                return setClass 'number'
                            
            if /^[a-fA-F\d][a-fA-F\d][a-fA-F\d]+$/.test word
                return setClass 'number hex'
                    
            # 00000000   00000000    0000000   00000000   00000000  00000000   000000000  000   000 
            # 000   000  000   000  000   000  000   000  000       000   000     000      000 000  
            # 00000000   0000000    000   000  00000000   0000000   0000000       000       00000   
            # 000        000   000  000   000  000        000       000   000     000        000    
            # 000        000   000   0000000   000        00000000  000   000     000        000    
                  
            if char == ':'
                if obj.ext in ['js', 'coffee', 'json']
                    return setClass 'dictionary key'
            
            if obj.last in ['.', ':']
                if obj.ext in ['js', 'coffee', 'json']
                    if getValue(-2) in ['text', 'module']
                        setValue -2, 'obj'
                        setValue -1, 'obj punctuation'
                        return setClass 'property'
                            
            if obj.last.endsWith '.'
                if obj.ext in ['js', 'coffee']                                               
                    if getValue(-2) == 'property'
                        setValue -1, 'property punctuation'
                        return setClass 'property'
                    else
                        if obj.last.length > 1 and obj.last[obj.last.length-2] in [')', ']']
                            setValue -1, 'property punctuation'
                            return setClass 'property'
            return setClass 'text'
        null
            
    # 00000000  000   000  0000000                   
    # 000       0000  000  000   000                 
    # 0000000   000 0 000  000   000                 
    # 000       000  0000  000   000  000  000  000  
    # 00000000  000   000  0000000    000  000  000  
    
    @endComment: (obj) ->
        
        bot = first obj.stack
        
        if bot?.type == 'comment'
            obj.rgs.push
                start: bot.index
                match: bot.match
                value: 'comment'
        null
                    
    @endTurd: (obj) ->
        
        obj.word += obj.char
        if valid obj.turd
            obj.last = obj.turd
            obj.turd = ''
            
        null

    # 00000000   000   000  000   000   0000000  000000000  
    # 000   000  000   000  0000  000  000          000     
    # 00000000   000   000  000 0 000  000          000     
    # 000        000   000  000  0000  000          000     
    # 000         0000000   000   000   0000000     000     
    
    @doPunct: (obj) ->
        
        char = obj.char
        
        value = 'punctuation'
        
        switch char
            when ':'
                if obj.turd.length == 1 and obj.ext in ['js', 'coffee', 'json', 'yml', 'yaml']
                    if last(obj.rgs).value == 'dictionary key'
                        value = 'dictionary punctuation'
        
        obj.rgs.push
            start: obj.index
            match: char
            value: value

        switch char 
            when '{' 
                if obj.ext == 'coffee' and last(obj.turd) == '#' and first(obj.stack).type == 'comment' and first(obj.stack).index == obj.index
                    obj.stack = []
            when '/' 
                if obj.ext not in @noSlashComment
                    if last(obj.turd) == '/' and empty obj.stack
                        obj.rgs.push
                            start: obj.index-1
                            match: '//'
                            value: "comment punctuation"
                        obj.stack.push type:'comment', index:obj.index, match:''
                        
        null
                        
    # 0000000     0000000    0000000  000000000   0000000    0000000  000   000  
    # 000   000  000   000  000          000     000   000  000       000  000   
    # 000   000  000   000  0000000      000     000000000  000       0000000    
    # 000   000  000   000       000     000     000   000  000       000  000   
    # 0000000     0000000   0000000      000     000   000   0000000  000   000  
    
    @doStack: (obj) ->
        
        char = obj.char
        
        stringType = switch char
            when "'" then 'string single'
            when '"' then 'string double'
            when '`' then 'string backtick'
            when "#" 
                if obj.ext in ['noon']
                    if empty(obj.words) and empty obj.turd.trim()
                        'comment'
                    else
                        Syntax.doPunct obj
                else if obj.ext in Syntax.hashComment 
                    'comment'
                else
                    Syntax.doPunct obj
            
        if not stringType
            Syntax.stackChar obj, char
            return
                
        if empty(obj.stack) or last(obj.stack)?.type == stringType        
            obj.rgs.push
                start: obj.index
                match: char
                value: "#{stringType} punctuation"
            
        if last(obj.turd) == '\\'
            Syntax.stackChar obj
            return
            
        if last(obj.stack)?.type == stringType and stringType != 'comment'
            top = obj.stack.pop()
            obj.rgs.push
                start: top.index
                match: top.match
                value: "#{stringType}"
        else
            if empty obj.stack
                obj.stack.push type:stringType, index:obj.index+1, match:''
            else
                Syntax.stackChar obj, char
                
        null

    #  0000000  000000000   0000000    0000000  000   000   0000000  000   000   0000000   00000000   
    # 000          000     000   000  000       000  000   000       000   000  000   000  000   000  
    # 0000000      000     000000000  000       0000000    000       000000000  000000000  0000000    
    #      000     000     000   000  000       000  000   000       000   000  000   000  000   000  
    # 0000000      000     000   000   0000000  000   000   0000000  000   000  000   000  000   000  
    
    @stackChar: (obj) -> 
        
        for item in obj.stack
            item.match += obj.char
            
        null
                
module.exports = Syntax
