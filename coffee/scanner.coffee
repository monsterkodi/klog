###
 0000000   0000000   0000000   000   000  000   000  00000000  00000000 
000       000       000   000  0000  000  0000  000  000       000   000
0000000   000       000000000  000 0 000  000 0 000  0000000   0000000  
     000  000       000   000  000  0000  000  0000  000       000   000
0000000    0000000  000   000  000   000  000   000  00000000  000   000
###

{ valid, slash, first, empty, noon, str, fs, error, _ } = require 'kxk'

log             = console.log
findit          = require 'findit2'
prettyTime      = require 'pretty-ms'
{ performance } = require 'perf_hooks'

class Scanner

    constructor: (@dir, @search, exts) ->
        
        @maxLineLength = 400
        
        @chunks = {}
        @lineno = {}
        @queue  = []
        
        @whitelist = exts.filter((ext) -> ext[0] == '.').map (ext) -> ext.slice 1
        @blacklist = exts.filter((ext) -> ext[0] == '!').map (ext) -> ext.slice 1
        
        @fileCount = 0
        @scanCount = 0
        @lineCount = 0
        
        @scanStart = performance.now()
        
        try
            @walker = findit @dir
                                
            @walker.on 'directory', @onDir            
            @walker.on 'file',      @onFile            
            @walker.on 'end',       @onEnd               
            @walker.on 'stop',      @onEnd               
            @walker.on 'error', (err) -> log 'error!', err.stack
                
        catch err
            error "Scanner.start -- #{err} dir: #{@dir} stack:", err.stack
        
    shouldScan: (file) ->
        
        if valid @whitelist
            return slash.ext(file) in @whitelist
        else if valid @blacklist
            if slash.ext(file) in @blacklist
                return false
            return true
        return true
                        
    #  0000000   000   000        00000000  000  000      00000000  
    # 000   000  0000  000        000       000  000      000       
    # 000   000  000 0 000        000000    000  000      0000000   
    # 000   000  000  0000        000       000  000      000       
    #  0000000   000   000        000       000  0000000  00000000  
    
    onFile: (file, stat) =>

        if @shouldScan(file) and slash.isText(file) 
            @queue.push slash.path file
            if @queue.length == 1 then @parseFile first @queue
            
    #  0000000   000   000        0000000    000  00000000   
    # 000   000  0000  000        000   000  000  000   000  
    # 000   000  000 0 000        000   000  000  0000000    
    # 000   000  000  0000        000   000  000  000   000  
    #  0000000   000   000        0000000    000  000   000  
    
    onDir: (dir, stat, stop) =>
        
        dirName = slash.file dir
        if dirName in ['node_modules', '.git']
            stop()
        if dirName.endsWith '-x64'
            stop()
                        
    # 0000000    00000000   0000000   000   000  00000000  000   000  00000000  
    # 000   000  000       000   000  000   000  000       000   000  000       
    # 000   000  0000000   000 00 00  000   000  0000000   000   000  0000000   
    # 000   000  000       000 0000   000   000  000       000   000  000       
    # 0000000    00000000   00000 00   0000000   00000000   0000000   00000000  
    
    dequeue: ->
        
        @queue.shift()
        if valid @queue
            @parseFile first @queue
        else if @walker == null
            @sendResult()
        
    # 00000000    0000000   00000000    0000000  00000000  
    # 000   000  000   000  000   000  000       000       
    # 00000000   000000000  0000000    0000000   0000000   
    # 000        000   000  000   000       000  000       
    # 000        000   000  000   000  0000000   00000000  
    
    parseFile: (file) ->
        
        @scanCount++
        @chunks[file] = []
        @lineno[file] = 0
        
        fileChunk = (f) => (chunk) => @onFileChunk f, chunk
        fileEnd   = (f) =>      () => @onFileEnd f
        
        stream = fs.createReadStream file, encoding:'utf8'
        stream.on 'error', @dequeue
        stream.on 'end',   fileEnd   file
        stream.on 'data',  fileChunk file
        
    # 00000000  000  000      00000000  00000000  000   000  0000000    
    # 000       000  000      000       000       0000  000  000   000  
    # 000000    000  000      0000000   0000000   000 0 000  000   000  
    # 000       000  000      000       000       000  0000  000   000  
    # 000       000  0000000  00000000  00000000  000   000  0000000    
    
    onFileEnd: (file) ->
        
        if valid @chunks[file]
            @fileCount++
            @send 
                id:     'file'
                type:   'file'
                sep:    ''
                file:   slash.base file 
                source: slash.tilde file
                str:    slash.tilde file 
            
            for chunk in @chunks[file]
                @lineCount++
                @send chunk
                
        @dequeue()
        
    #  0000000  000   000  000   000  000   000  000   000  
    # 000       000   000  000   000  0000  000  000  000   
    # 000       000000000  000   000  000 0 000  0000000    
    # 000       000   000  000   000  000  0000  000  000   
    #  0000000  000   000   0000000   000   000  000   000  
    
    onFileChunk: (file, chunk) -> 
        
        for data in chunk.split /\r?\n/
            
            @lineno[file]++
            
            if data.length > @maxLineLength
                data = data.substr 0, @maxLineLength
                
            if empty @search
                column = 0
            else
                column = data.indexOf(@search)
            if column >= 0
                @chunks[file].push 
                    id:     'find' 
                    file:   ''
                    icon:   ''
                    type:   'find'
                    line:   @lineno[file]
                    column: column
                    source: slash.tilde file
                    str:    data
                    find:   @search
                    sep:    ''

    onEnd: => 
                
        @walker = null
        if empty @queue
            @sendResult()

    # 00000000   00000000   0000000  000   000  000      000000000  
    # 000   000  000       000       000   000  000         000     
    # 0000000    0000000   0000000   000   000  000         000     
    # 000   000  000            000  000   000  000         000     
    # 000   000  00000000  0000000    0000000   0000000     000     
    
    sendResult: =>
        
        @send
            id:     'klog'
            type:   'win'
            file:   'find'
            ext:    'txt'
            sep:    '▶'
            icon:   slash.fileUrl slash.join __dirname, '../img/menu@2x.png'
            str:    @stats()

    stats: ->
        
        time = prettyTime performance.now()-@scanStart
        time = time.replace 'ms', ' ms'
        "find '#{@search}' in '#{slash.tilde @dir}': #{@lineCount} lines in #{@fileCount} files (#{@scanCount} files scanned in #{time})"
            
    #  0000000  000000000   0000000   00000000   
    # 000          000     000   000  000   000  
    # 0000000      000     000   000  00000000   
    #      000     000     000   000  000        
    # 0000000      000      0000000   000        
    
    stop: ->
        
        @walker?.stop()
        @walker = null
        
    send: (obj) ->
            
        if _.isFunction process.send
            process.send obj
        else
            log JSON.stringify obj
        
process.on 'uncaughtException', (err) ->
    log 'scanner error!', err.stack
    true
    
if not empty process.argv[2]
    dir    = process.argv[2]
    search = process.argv[3]
    exts   = [].slice.call(process.argv).slice 4
        
    new Scanner slash.resolve(dir), search, exts
    
