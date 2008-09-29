spec = Gem::Specification.new do |s|
    s.name = 'hoptoad-notifier-ramaze'
    s.version = '0.6.1'
    s.summary = 'A hoptoadapp.com notifier for Ramaze.'
    s.description = 'Send errors from your Ramaze applications to hoptoadapp.com.'
    s.homepage = 'http://github.com/Pistos/hoptoad-notifier-ramaze'
    
    s.authors = [ 'Pistos' ]
    s.email = 'pistos at purepistos dot net'
    
    s.files = [
        'README.markdown',
        'LICENCE',
        'lib/hoptoad-notifier.rb',
        'lib/hash.rb',
    ]
    s.extra_rdoc_files = [ 'README.markdown', 'LICENCE', ]
end
