###
000000000  00000000   0000000  000000000
   000     000       000          000   
   000     0000000   0000000      000   
   000     000            000     000   
   000     00000000  0000000      000   
###

{ log } = require 'kxk'

Syntax = require './syntax'
assert = require 'assert'
chai   = require 'chai'
expect = chai.expect
chai.should()

describe 'klog', ->
    
    describe 'syntax', ->

        it 'punctuation', ->
            
            rgs = Syntax.ranges '/some\\path/file.txt:10'
            log rgs
            expect(rgs).to.deep.include 
                start: 0
                match: '/'
                value: 'punctuation'

            expect(rgs).to.deep.include 
                start: 5
                match: '\\'
                value: 'punctuation'
                
            expect(rgs).to.deep.include 
                start: 15
                match: '.'
                value: 'punctuation'
                
            expect(rgs).to.deep.include 
                start: 19
                match: ':'
                value: 'punctuation'