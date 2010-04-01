# set :env,  :production
# disable :run

require 'rubygems'
require 'uv'
require 'rack/codehighlighter'

require 'blog'

THEME="twilight"

# Code Highlighting
use(Rack::Codehighlighter, :ultraviolet,
    :markdown => true, :theme => THEME, :lines => false,
    :element => "pre>code", :pattern => /\A:::([-_+\w]+)\s*(\n|&#x000A;)/,
    :logging => true)

run Sinatra::Application
