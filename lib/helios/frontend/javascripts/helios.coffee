window.Helios = {
  Version: "0.0.1"

  Models: {}
  Collections: {}
  Views: {}
  Routers: {}

  initialize: ->
    window.app = new Helios.Routers.Root
    for entity in Helios.entities.models
      do (entity) ->
        name = entity.get('name').toLowerCase()
        window.app[name] = ->
          @views.entity = new Helios.Views.Entity({model: entity})
        window.app.route entity.url(), name

    window.app.views.entities = new Helios.Views.Entities({collection: Helios.entities})
    window.app.views.entities.render()

    Backbone.history.start({
      root: window.location.pathname,
      pushState: false,
      hashChange: true
    })
}

$ ->
  $(document).foundation()
  $('body').delegate 'a[href^=#]', 'click', (event) ->
    event.preventDefault()
    href = $(this).attr('href')
    window.app.navigate(href, {trigger: true, replace: true})

  Helios.entities = new Helios.Collections.Entities
  Helios.entities.fetch(type: 'OPTIONS', success: Helios.initialize, error: Helios.initialize)
