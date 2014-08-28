require 'fileutils'

command :new do |c|
  c.syntax = 'helios new path/to/app'
  c.summary = 'Creates a new Helios project'
  c.description = <<-EOF
  The `helios new` command creates a new Helios application with a default
  directory structure and configuration at the path you specify.
  EOF
  # c.example = <<-EOF
  # helios new #{File.join(Dir.pwd, "app")}

  # This generates a skeletal Helios installation in #{File.join(Dir.pwd, "app")}.
  # See the README in the newly created application to get going.
  # EOF

  c.option '--skip-gemfile', "Don't create a Gemfile"
  c.option '-B', '--skip-bundle', "Don't run bundle install"
  c.option '-G', '--skip-git', "Don't create a git repository"

  c.option '--edge', "Setup the application with Gemfile pointing to Helios repository"

  c.option '-f', '--force', "Overwrite files that already exist"
  c.option '-p', '--pretend', "Run but do not make any changes"
  c.option '-s', '--skip', "Skip files that already exist"

  c.action do |args, options|
    say_error "Missing argument: path/to/app" and abort if args.empty?
    path = args.first
    app_name = path.split(/\//).last

    begin
      FileUtils.mkdir_p(path) and Dir.chdir(path)

      Dir.glob(File.join(File.dirname(__FILE__), "../templates/") + "*.erb", File::FNM_DOTMATCH).each do |template|
        file = File.basename(template, ".erb")
        erb = ERB.new(File.read(template))

        next if file === "Gemfile" and options.skip_gemfile
        next if file === ".gitignore" and options.skip_git

        if File.exist?(file)
          if options.force and not options.skip
            log "overwrite", file
          else
            log "exists", file
          end
        else
          log "create", file
        end

        next if options.pretend

        File.open(file, 'w') do |f|
          f.puts erb.result binding
        end
      end

      unless options.skip_bundle or not File.exist?("Gemfile")
        log "run", "bundle install"
        system 'bundle install'
      end

      unless options.skip_git
        log "run", "git init"
        system 'git init'
        system 'git add .'
        system 'git commit -m "Initial Commit"'
      end
    rescue => exception
      say_error exception.message and abort
    end
  end
end

alias_command :create, :new
alias_command :generate, :new
