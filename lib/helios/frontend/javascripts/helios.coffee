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
    window.app.views.entities.render() if Helios.services['data']

    Backbone.history.start({
      root: window.location.pathname,
      pushState: false,
      hashChange: true
    })
}

$ ->
  $.fn.serializeMultipart = ->
    obj = $(this)

    formData = new FormData()
    $.each $(obj).find("input[type='file']"), (i, tag) ->
      $.each $(tag)[0].files, (j, file) ->
        formData.append tag.name, file

    params = $(obj).serializeArray()
    $.each params, (i, val) ->
      formData.append val.name, val.value

    formData

  $(document).foundation()
  $('body').delegate 'a[href^=#]', 'click', (event) ->
    event.preventDefault()
    href = $(this).attr('href')
    window.app.navigate(href, {trigger: true, replace: true})

  Helios.services = {}
  $.ajax(type: 'OPTIONS', url: "/", success: (data, status, xhr) ->
    header = xhr.getResponseHeader("Link")
    $.linkheaders(header).each (idx, link) ->
      href = link.attr('href')
      rel = link.rels()[0]

      switch rel
        when "Helios::Backend::Data"
          Helios.services['data'] = href
        when "Helios::Backend::InAppPurchase"
          Helios.services['in-app-purchase'] = href
        when "Helios::Backend::Newsstand"
          Helios.services['newsstand'] = href
        when "Helios::Backend::PushNotification"
          Helios.services['push-notification'] = href
        when "Helios::Backend::Passbook"
          Helios.services['passbook'] = href

    Helios.entities = new Helios.Collections.Entities
    Helios.entities.fetch(type: 'OPTIONS', url: (Helios.services['data'] || "") + '/resources', success: Helios.initialize, error: Helios.initialize)
  )

