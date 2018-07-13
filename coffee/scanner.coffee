###
 0000000   0000000   0000000   000   000  000   000  00000000  00000000 
000       000       000   000  0000  000  0000  000  000       000   000
0000000   000       000000000  000 0 000  000 0 000  0000000   0000000  
     000  000       000   000  000  0000  000  0000  000       000   000
0000000    0000000  000   000  000   000  000   000  00000000  000   000
###

{ slash, first, valid, empty, fs, error, log, _ } = require 'kxk'

log             = console.log
findit          = require 'findit2'
prettyTime      = require 'pretty-ms'
{ performance } = require 'perf_hooks'

class Scanner

    constructor: (@dir, @search) ->
        
        @chunks = {}
        @queue  = []
        
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
        
    stats: ->
        
        time = prettyTime performance.now()-@scanStart
        "#{@lineCount} lines in #{@fileCount} files contain '#{@search}' (#{@scanCount} files scanned in #{time})"
            
    #  0000000   000   000        00000000  000  000      00000000  
    # 000   000  0000  000        000       000  000      000       
    # 000   000  000 0 000        000000    000  000      0000000   
    # 000   000  000  0000        000       000  000      000       
    #  0000000   000   000        000       000  0000000  00000000  
    
    onFile: (file, stat) =>

        if slash.isText file
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
        
    parseFile: (file) ->
        
        @scanCount++
        @chunks[file] = []
        
        fileChunk = (f) => (chunk) => @onFileChunk f, chunk
        fileEnd   = (f) =>      () => @onFileEnd f
        
        stream = fs.createReadStream file, encoding:'utf8'
        stream.on 'error', @dequeue
        stream.on 'end',   fileEnd   file
        stream.on 'data',  fileChunk file
        
    onFileEnd: (file) ->
        
        if valid @chunks[file]
            @fileCount++
            @send 
                id:     'file'
                type:   'file'
                icon:   '☉'
                file:   slash.base(file)
                source: file
                str:    slash.tilde(file) #+ " #{@chunks[file].length}"
            
            for chunk in @chunks[file]
                @lineCount++
                @send chunk
                
        @dequeue()
        
    onFileChunk: (file, chunk) -> 
        
        for data in chunk.split '\n'
            
            if data.length > 1024
                data = data.substr 0, 1024
                
            if data.indexOf(@search) >= 0
                @chunks[file].push 
                    id:     'find' 
                    file:   ''
                    icon:   ''
                    type:   'find'
                    source: file
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
            id:     'file'
            type:   'file'
            file:   'scanner'
            source: slash.path __filename
            str:    @stats()
                
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
    log 'scanner error', err.stack
    true
    
if not empty process.argv[2]
    if empty process.argv[3]
        dir    = process.cwd()
        search = process.argv[2]
    else
        dir    = process.argv[2]
        search = process.argv[3]
        
    new Scanner slash.resolve(dir), search
    
