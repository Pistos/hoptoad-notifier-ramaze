require 'net/http'
require 'yaml'
require 'ramaze'
require 'ramaze/helper/aspect'
require File.join(__DIR__, 'hash')

# Setup your project's API key prior to use:
#   Ramaze::Helper::HoptoadNotifier.trait[ :api_key ] = 'your-key-here'

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
            'request'       => { 'params' => req.params, },
            'error_class'   => error.class.name,
            'error_message' => "#{error.class.name}: #{error.message}",
            'backtrace'     => error.backtrace,
            'environment'   => ENV.to_hash.merge( req.env ),
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
          Ramaze::Log.debug "Hoptoad notification sent."
        else
          Ramaze::Log.error "Hoptoad notification failure: #{response.class}"
          if response.respond_to? :body
            Ramaze::Log.error response.body
          end
        end
      end            
    end

  end
  
  class Controller
    helper :hoptoad_notifier
    send_errors_to_hoptoad
  end
end

Ramaze::Log.info "Ramaze Hoptoad Notifier version 0.6.1 loaded."
