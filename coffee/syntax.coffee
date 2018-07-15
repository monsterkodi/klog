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

    @noCommentExt      = ['txt', 'md']
    @hashCommentExt    = ['coffee', 'sh', 'yml', 'yaml', 'noon']
    @noSlashCommentExt = Syntax.noCommentExt.concat Syntax.hashCommentExt
    
    # 00000000  000   000  0000000    000   000   0000000   00000000   0000000    
    # 000       0000  000  000   000  000 0 000  000   000  000   000  000   000  
    # 0000000   000 0 000  000   000  000000000  000   000  0000000    000   000  
    # 000       000  0000  000   000  000   000  000   000  000   000  000   000  
    # 00000000  000   000  0000000    00     00   0000000   000   000  0000000    
    
    @endWord: (obj, char) ->
        
        if valid obj.word
            
            word = obj.word
            
            obj.words.push word
            obj.word = ''

            log "@endWord #{word}"
            
            getValue = (back=-1) ->
                if char not in [' ', undefined] # punctuation that triggered addWord is already on stack!
                    back -= 1                   # therefore adjust back index
                obj.rgs[obj.rgs.length+back]?.value 
                
            setValue = (back, value) ->
                if char not in [' ', undefined] # punctuation that triggered addWord is already on stack!
                    back -= 1                   # therefore adjust back index
                obj.rgs[obj.rgs.length+back].value = value
            
            switch obj.ext 
                when 'js', 'coffee'
                    clss = switch word
                        when 'first', 'last', 'valid', 'empty', 'clamp', 'watch', 'str', 'pos', 'elem', 'stopEvent', 'if', 'else', 'then', 'for', 'of', 'in', 'is', 'while', 'do', 'unless', 'not', 'or', 'and', 'try', 'catch', 'return', 'break', 'continue', 'new', 'switch', 'when', 'super', 'extends', 'by', 'true'
                            'keyword'
                        when 'post', 'childp', 'matchr', 'prefs', 'slash', 'noon', 'args', 'console','process','global','module','exports','fs','os'
                            'module'                    
                        when 'log'
                            'function'
                        when 'err', 'error'
                            'function call'
                        when 'undefined', 'null', 'false'
                            'nil'
                        when 'require'
                            'require'
                        when 'dirname', 'filename'
                            if obj.last.endsWith '__'
                                setValue -2, 'keyword punctuation'
                                setValue -1, 'keyword punctuation'
                                'keyword' 
                    
            if not clss
                if /^\d+$/.test word
                    if obj.last == '.'                        
                        if getValue(-4) == 'number float' and getValue(-2) == 'number float'
                            setValue -4, 'semver'
                            setValue -3, 'semver punctuation'
                            setValue -2, 'semver'
                            setValue -1, 'semver punctuation'
                            clss = 'semver'
                                
                        if not clss 
                            if getValue(-2) == 'number'
                                setValue -2, 'number float'
                                setValue -1, 'punctuation float'
                                clss = 'number float'
                    clss ?= 'number'
                                
                else if /^[a-fA-F\d][a-fA-F\d][a-fA-F\d]+$/.test word
                    clss = 'number hex'
                  
            log "@endWord2 #{word}", str obj
            
            if not clss
                if char == ':'
                    if obj.ext in ['js', 'coffee', 'json']
                        clss = 'property'
            
            if not clss
                if obj.last in ['.', ':']
                    if obj.ext in ['js', 'coffee', 'json']
                        if getValue(-2) in ['text', 'module']
                            setValue -2, 'obj'
                            setValue -1, 'punctuation obj'
                            clss = 'property'
                            
            if not clss 
                if obj.last.endsWith '.'
                    if obj.ext in ['js', 'coffee']                                               
                        if getValue(-2) == 'property'
                            setValue -1, 'punctuation property'
                            clss = 'property'
                        else
                            log 'obj.last', obj.last
                            if obj.last.length > 1 and obj.last[obj.last.length-2] in [')', ']']
                                setValue -1, 'punctuation property'
                                clss = 'property'
            clss ?= 'text'

            lastStart = last(obj.rgs)?.start
            if lastStart and lastStart > obj.index - word.length
                popped = obj.rgs.pop()
                
            obj.rgs.push
                start: obj.index - word.length
                match: word
                value: clss
                
            if popped 
                obj.rgs.push popped
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
                    
    @endRest: (obj) ->
        
        if valid obj.rest
            obj.last = obj.rest
            obj.rest = ''
            
        null

    # 00000000   000   000  000   000   0000000  000000000  
    # 000   000  000   000  0000  000  000          000     
    # 00000000   000   000  000 0 000  000          000     
    # 000        000   000  000  0000  000          000     
    # 000         0000000   000   000   0000000     000     
    
    @doPunctuation: (obj, char) ->
        
        obj.rgs.push
            start: obj.index
            match: char
            value: 'punctuation'
            
        null
                        
    # 0000000     0000000    0000000  000000000   0000000    0000000  000   000  
    # 000   000  000   000  000          000     000   000  000       000  000   
    # 000   000  000   000  0000000      000     000000000  000       0000000    
    # 000   000  000   000       000     000     000   000  000       000  000   
    # 0000000     0000000   0000000      000     000   000   0000000  000   000  
    
    @doStack: (obj, char) ->
        
        stringType = switch char
            when "'" then 'string single'
            when '"' then 'string double'
            when '`' then 'string backtick'
            when "#" 
                if obj.ext in ['noon']
                    if empty(obj.words) and empty obj.rest.trim()
                        'comment'
                    else
                        Syntax.doPunctuation obj, char
                else if obj.ext in Syntax.hashCommentExt 
                    'comment'
                else
                    Syntax.doPunctuation obj, char
            
        if not stringType
            Syntax.stackChar obj, char
            return
                
        if empty(obj.stack) or last(obj.stack)?.type == stringType        
            obj.rgs.push
                start: obj.index
                match: char
                value: "#{stringType} punctuation"
            
        if last(obj.rest) == '\\'
            # log 'escaped'
            Syntax.stackChar obj, char
            return
            
        if last(obj.stack)?.type == stringType and stringType != 'comment'
            top = obj.stack.pop()
            # log 'pop', stringType, top
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

    @stackChar: (obj, char) -> 
        
        for item in obj.stack
            item.match += char
            
        null
                
    # 00000000    0000000   000   000   0000000   00000000   0000000  
    # 000   000  000   000  0000  000  000        000       000       
    # 0000000    000000000  000 0 000  000  0000  0000000   0000000   
    # 000   000  000   000  000  0000  000   000  000            000  
    # 000   000  000   000  000   000   0000000   00000000  0000000   
    
    @ranges: (string, ext) ->
        
        obj =
            ext:    ext ? 'txt'
            rgs:    []
            words:  []
            stack:  []
            word:   ''
            rest:   ''
            last:   ''
            index:  0
        
        for char in string
            
            wordEnd   = true
            stackChar = true
            
            switch char
                
                when "'", '"', '`', '#'
                    Syntax.doStack obj, char
                    stackChar = false
                when '_', '+', '-', '*', '<', '>', '=', '^', '~', '@', '$', '%', '/', '\\', ':', '.', ';', ',', '!', '|', '{', '}', '(', ')', '[', ']'
                    Syntax.doPunctuation obj, char
                        
                    switch char 
                        when '{' 
                            if obj.ext == 'coffee' and last(obj.rest) == '#' and first(obj.stack).type == 'comment' and first(obj.stack).index == obj.index
                                obj.stack = []
                        when '/' 
                            if obj.ext not in @noSlashCommentExt
                                if last(obj.rest) == '/' and empty obj.stack
                                    obj.rgs.push
                                        start: obj.index-1
                                        match: '//'
                                        value: "comment punctuation"
                                    obj.stack.push type:'comment', index:obj.index, match:''
                            
                when ' ' then
                else
                    wordEnd = false
                    
            if wordEnd 
                obj.rest += char
                Syntax.endWord obj, char
            else
                obj.word += char
                Syntax.endRest obj
                    
            if stackChar
                Syntax.stackChar obj, char
                
            obj.index++
            
        Syntax.endWord obj
        Syntax.endComment obj
            
        # log 'Syntax', str obj
        
        obj.rgs

module.exports = Syntax
