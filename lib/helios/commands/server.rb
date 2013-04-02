command :server do |c|
  c.syntax = 'helios server'
  c.summary = 'Start running Helios locally'

  c.action do |args, options|
    begin
      exec 'foreman start'
    rescue => exception
      say_error exception.message and abort
    end
  end
end

alias_command :s, :server
alias_command :start, :server
alias_command :launch, :server
