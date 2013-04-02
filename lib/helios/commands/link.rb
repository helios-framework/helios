require 'fileutils'

command :link do |c|
  c.syntax = 'helios link path/to/Model.xcdatamodel'
  c.summary = 'Links a Core Data model'

  c.action do |args, options|
    say_error "Missing argument: path/to/Model.xcdatamodel" and abort if args.empty?
    path = args.first

    begin
      File.link(path, File.basename(path))
      say_ok "Xcode data model successfully linked"
      say "Any changes made to the data model file will automatically be propagated to Helios the next time the server is started."
    rescue => exception
      say_error exception.message and abort
    end
  end
end
