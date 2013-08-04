require 'sinatra/base'
require 'sinatra/assetpack'
require 'sinatra/backbone'
require 'sinatra/support'
require 'rack/contrib'

require 'compass'
require 'zurb-foundation'
require 'haml'

module Helios
  class Frontend < Sinatra::Base
    set :root, File.join(File.dirname(__FILE__), "frontend")
    set :sass, load_paths: ["#{self.root}/stylesheets"]

    register Sinatra::CompassSupport
    register Sinatra::AssetPack
    register Sinatra::JstPages

    use Rack::BounceFavicon

    assets do
      serve '/javascripts', from: '/javascripts'
      serve '/stylesheets', from: '/stylesheets'
      serve '/images', from: '/images'
      serve '/fonts', from: '/fonts'

      js :application, '/javascripts/application.js', [
        '/javascripts/vendor/jquery.js',
        '/javascripts/vendor/jquery/jquery.ui.widget.js',
        '/javascripts/vendor/jquery/jquery.fileupload.js',
        '/javascripts/vendor/jquery/jquery.fileupload-ui.js',
        '/javascripts/vendor/underscore.js',
        '/javascripts/vendor/backbone.js',
        '/javascripts/vendor/backbone.paginator.js',
        '/javascripts/vendor/backbone.datagrid.js',
        '/javascripts/vendor/codemirror.js',
        '/javascripts/vendor/codemirror.javascript.js',
        '/javascripts/vendor/foundation.js',
        '/javascripts/vendor/foundation/foundation.dropdown.js',
        '/javascripts/vendor/foundation/foundation.reveal.js',
        '/javascripts/vendor/date.js',
        '/javascripts/vendor/linkheaders.js',
        '/javascripts/helios.js',
        '/javascripts/helios/models.js',
        '/javascripts/helios/collections.js',
        '/javascripts/helios/templates.js',
        '/javascripts/helios/views.js',
        '/javascripts/helios/router.js',
      ]

      css :application, '/stylesheets/application.css', [
        '/stylesheets/screen.css'
      ]
    end

    serve_jst '/javascripts/helios/templates.js', root: settings.root + '/templates'

    get '' do
      redirect request.fullpath + "/"
    end

    get '/' do
      haml :index
    end
  end
end

# Workaround for Sinatra::Assetpack bug
# See https://github.com/helios-framework/helios/issues/68
class Sinatra::AssetPack::Package
  def to_production_html(path_prefix, options={})
    to_development_html(path_prefix, options)
  end
end
