#!/usr/bin/env ruby

require 'rubygems'

spec = Gem::Specification.new do |s|
    s.name = 'hoptoad-notifier-ramaze'
    s.version = '0.5.0'
    s.summary = 'A hoptoadapp.com notifier for Ramaze.'
    s.description = 'Send Ramaze errors to hoptoadapp.com.'
    s.homepage = 'http://github.com/Pistos/hoptoad-notifier-ramaze'
    #s.rubyforge_project = 'hoptoad-notifier-ramaze'
    
    s.authors = [ 'Pistos' ]
    s.email = 'pistos at purepistos dot net'
    
    #s.platform = Gem::Platform::RUBY
    
    s.files = [
        'README',
        'LICENCE',
        *( Dir[ 'lib/*.rb' ] )
    ]
    s.extra_rdoc_files = [ 'README', 'LICENCE', ]
end

if $PROGRAM_NAME == __FILE__
    Gem::Builder.new( spec ).build
end