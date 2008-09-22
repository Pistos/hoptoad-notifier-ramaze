# Run with:
#   ruby example.rb
# Then browse to http://localhost:7000

require 'rubygems'
require 'ramaze'
require './lib/hoptoad-notifier'

# Set your project's API key here.
# Note that this is not your user API key.
Rack::HoptoadNotifier.trait[ :api_key ] = 'your-api-key-here'

class MainController < Ramaze::Controller
  def index
    session[ :user ] = 'pistos'
    "Hello, World!"
    foo  # cause an exception
  end
end

Ramaze.start