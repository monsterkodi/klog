###
 0000000   0000000   0000000   000   000  000   000  00000000  00000000 
000       000       000   000  0000  000  0000  000  000       000   000
0000000   000       000000000  000 0 000  000 0 000  0000000   0000000  
     000  000       000   000  000  0000  000  0000  000       000   000
0000000    0000000  000   000  000   000  000   000  00000000  000   000
###

{ post, slash, walkdir, elem, empty, valid, fs, $, _ } = require 'kxk'

log    = console.log
findit = require 'findit2'

class Scanner

    constructor: (@dir, @search) ->
        
        @chunks = {}
        
        try
            @walker = findit @dir, no_recurse:false, track_inodes:false
                                
            @walker.on 'directory', @onDir            
            @walker.on 'file',      @onFile            
            @walker.on 'end',       @onEnd               
            @walker.on 'stop',      @onEnd               
            @walker.on 'error', ->
                
        catch err
            error "Scanner.start -- #{err} dir: #{@dir} stack:", err.stack
        
    #  0000000   000   000        00000000  000  000      00000000  
    # 000   000  0000  000        000       000  000      000       
    # 000   000  000 0 000        000000    000  000      0000000   
    # 000   000  000  0000        000       000  000      000       
    #  0000000   000   000        000       000  0000000  00000000  
    
    onFile: (file, stat) =>

        if slash.isText file
            @addFile slash.path file
            
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
                        
    #  0000000   0000000    0000000         00000000  000  000      00000000  
    # 000   000  000   000  000   000       000       000  000      000       
    # 000000000  000   000  000   000       000000    000  000      0000000   
    # 000   000  000   000  000   000       000       000  000      000       
    # 000   000  0000000    0000000         000       000  0000000  00000000  
    
    addFile: (file) ->

        @chunks[file] = []
        
        fileChunk = (f) => (chunk) => @onFileChunk f, chunk
        fileEnd   = (f) =>         => @onFileEnd f
        
        stream = fs.createReadStream file, encoding:'utf8'
        stream.on 'error', ->
        stream.on 'end',   fileEnd   file
        stream.on 'data',  fileChunk file
        
    onFileEnd: (file) ->
        
        if valid @chunks[file]
            @send 
                id:     'file'
                type:   'file'
                file:   slash.base(file)
                source: file
                str:    slash.tilde(file)
            
            for chunk in @chunks[file]
                @send chunk
        
    onFileChunk: (file, chunk) -> 
        
        for data in chunk.split '\n'
            
            if data.indexOf(@search) >= 0
                @chunks[file].push 
                    id:     'find' 
                    file:   ''
                    type:   'find'
                    source: file
                    str:    data
                    find:   @search
                    sep:    ''

    onEnd: => @walker = null
                
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
    
