# set :env,  :production
# disable :run

# Add the rackup file path to the load path
$:.unshift File.dirname(__FILE__)

# Require our app
require 'lilyblog'

# Start up the app
run Sinatra::Application
