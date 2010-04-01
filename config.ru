# set :env,  :production
# disable :run

require 'rubygems'
require 'uv'
require 'rack/codehighlighter'
require 'blog'

THEME="twilight"

use(Rack::Codehighlighter, :ultraviolet,
    :markdown => true, :theme => THEME, :lines => false,
    :element => "pre>code", :pattern => /\A:::([-_+\w]+)\s*(\n|&#x000A;)/,
    :logging => false)

run Sinatra::Application
