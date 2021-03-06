load('heroku/helpers.rb') # reload helpers after possible inject_loadpath
load('heroku/updater.rb') # reload updater after possible inject_loadpath

require "heroku"
require "heroku/command"
require "heroku/helpers"

# workaround for rescue/reraise to define errors in command.rb failing in 1.8.6
if RUBY_VERSION =~ /^1.8.6/
  require('heroku-api')
  require('rest_client')
end

begin
  # attempt to load the JSON parser bundled with ruby for multi_json
  # we're doing this because several users apparently have gems broken
  # due to OS upgrades. see: https://github.com/heroku/heroku/issues/932
  require 'json'
rescue LoadError
  # let multi_json fallback to yajl/oj/okjson
end

class Heroku::CLI

  extend Heroku::Helpers

  def self.start(*args)
    begin
      if $stdin.isatty
        $stdin.sync = true
      end
      if $stdout.isatty
        $stdout.sync = true
      end
      command = args.shift.strip rescue "help"
      Heroku::Command.load
      Heroku::Command.run(command, args)
    rescue Interrupt
      `stty icanon echo`
      error("Command cancelled.")
    rescue => error
      styled_error(error)
      exit(1)
    end
  end

end
