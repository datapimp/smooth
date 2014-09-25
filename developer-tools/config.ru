require 'pathname'

run Rack::Directory.new Pathname(Dir.pwd).join("dist")
