require 'net/http'
require 'yaml'
require 'ramaze'
require 'ramaze/helper/aspect'
require __DIR__/'hash'

# Setup your project's API key prior to use:
#   Rack::HoptoadNotifier.trait[ :api_key ] = 'your-key-here'

module Ramaze
  module Helper::HoptoadNotifier
    include Ramaze::Helper::Aspect
    
    private
    
    def send_errors_to_hoptoad( api_key = nil )
      before :error do
        error = Ramaze::Dispatcher::Error.current
        session = Ramaze::Session.current
        req = Ramaze::Current.request
        
        send_to_hoptoad(
          'notice' => {
            'api_key'       => api_key || Ramaze::Helper::HoptoadNotifier.trait[ :api_key ],
            'request'       => {},
            'error_class'   => error.class.name,
            'error_message' => "#{error.class.name}: #{error.message}",
            'backtrace'     => error.backtrace,
            'environment'   => ENV.to_hash.merge( req.env ),
            'params'        => req.params,
            'session' => {
              'key' => session.session_id,
              'data' => session.to_h,
            },
          }
        )
      end
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
          Ramaze::Log.error "Timeout while contacting the Hoptoad server."
          nil
        end
        
        case response
        when Net::HTTPSuccess
          Ramaze::Log.debug "Hoptoad Success: #{response.class}"
        else
          Ramaze::Log.error "Hoptoad Failure: #{response.class}\n#{response.body if response.respond_to? :body}"
        end
      end            
    end

  end
  
  class Controller
    helper :hoptoad_notifier
    send_errors_to_hoptoad
  end
end

module Rack
  class HoptoadNotifier
    
    def initialize( app )
      @app = app
    end
    
    def call( env )
      @app.call env
    rescue => e
      s = Ramaze::Session.current
      notice_options = {
        'error_class' => e.class.name,
        'error_message' => "#{e.class.name}: #{e.message}",
        'backtrace' => e.backtrace,
        'environment' => ENV.to_hash.merge( Ramaze::Current.request.env ),
        'params' => Ramaze::Current.request.params,
        'session' => {
          'key' => s.session_id,
          'data' => s.to_h,
        },
      }
      send_to_hoptoad(
        'notice' => default_notice_options.merge( notice_options )
      )
      Ramaze::Dispatcher.error e
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
          Ramaze::Log.error "Timeout while contacting the Hoptoad server."
          nil
        end
        
        case response
        when Net::HTTPSuccess
          Ramaze::Log.debug "Hoptoad Success: #{response.class}"
        else
          Ramaze::Log.error "Hoptoad Failure: #{response.class}\n#{response.body if response.respond_to? :body}"
        end
      end            
    end
  
  end
end

#mw = Ramaze::Adapter::MIDDLEWARE
#current_index = mw.index( Ramaze::Dispatcher )
#mw.insert( current_index, Rack::HoptoadNotifier )

