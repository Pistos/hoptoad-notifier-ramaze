require 'net/http'
require 'yaml'

# Setup your project's API key prior to use:
#   Rack::HoptoadNotifier.trait[ :api_key ] = 'your-key-here'

module Rack
  class HoptoadNotifier
    
    def initialize( app )
      @app = app
    end
    
    def call( env )
      @app.call env
    rescue => e
      $stderr.puts "hoptoad rescued!"
      s = Ramaze::Session.current
      $stderr.puts "s: #{s.class}"
      notice_options = {
        'error_class' => e.class.name,
        'error_message' => "#{e.class.name}: #{e.message}",
        'backtrace' => e.backtrace,
        'environment' => ENV.to_hash,
        # TODO: merge request.env
        'params' => Ramaze::Current.request.params,
        #'session' => s,
      }
      send_to_hoptoad(
        'notice' => default_notice_options.merge( notice_options )
      )
      raise e
    end
    
    def default_notice_options
      {
        'api_key'       => self.class.trait[ :api_key ],
        'error_message' => 'Error Notification',
        'backtrace'     => caller,
        'request'       => {},
        'session'       => {},
        'environment'   => ENV.to_hash
      }
    end
    
    def send_to_hoptoad( data )
      url = URI.parse( 'http://hoptoadapp.com:80/notices/' )
      
      Net::HTTP.start( url.host, url.port ) do |http|
        headers = {
          'Content-type' => 'application/x-yaml',
          'Accept' => 'text/xml, application/xml'
        }
        http.read_timeout = 5 # seconds
        http.open_timeout = 2 # seconds
        # http.use_ssl = HoptoadNotifier.secure
        response = begin
          http.post( url.path, data.to_yaml, headers )
        rescue TimeoutError => e
          puts "Timeout while contacting the Hoptoad server."
          nil
        end
        
        case response
        when Net::HTTPSuccess
          puts "Hoptoad Success: #{response.class}"
        else
          puts "Hoptoad Failure: #{response.class}\n#{response.body if response.respond_to? :body}"
        end
      end            
    end
  
  end
end

mw = Ramaze::Adapter::MIDDLEWARE
current_index = mw.index( Ramaze::Current )
mw.insert( current_index + 1, Rack::HoptoadNotifier )
