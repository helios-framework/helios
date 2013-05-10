class Helios.Routers.Root extends Backbone.Router
  el:
    "div[role='main']"

  initialize: (options) ->
    @views = {}

    @views.navigation = new Helios.Views.Navigation
    @views.navigation.render()

    super

  routes:
    '':                   'index'
    'data':               'data'
    'push-notification':  'push_notification'
    'in-app-purchase':    'in_app_purchase'
    'passbook':           'passbook'
    'newsstand':          'newsstand'

  index: ->
    Helios.entities.fetch(type: 'OPTIONS')

  data: ->
    Helios.entities.fetch(type: 'OPTIONS')
    @views.entities.render()

  push_notification: ->
    @devices ?= new Helios.Collections.Devices
    @devices.paginator_core.url = Helios.services['push-notification'] + '/devices'
    @views.devices ?= new Helios.Views.Devices(collection: @devices)
    @views.devices.render()

  in_app_purchase: ->
    @receipts ?= new Helios.Collections.Receipts
    @receipts.paginator_core.url = Helios.services['in-app-purchase'] + '/receipts'
    @views.receipts ?= new Helios.Views.Receipts(collection: @receipts)
    @views.receipts.render()

  passbook: ->
    @passes ?= new Helios.Collections.Passes
    @passes.paginator_core.url = Helios.services['passbook'] + '/passes'
    @views.passes ?= new Helios.Views.Passes(collection: @passes)
    @views.passes.render()

  newsstand: ->
    @issues ?= new Helios.Collections.Issues
    @issues.paginator_core.url = Helios.services['newsstand'] + '/issues'
    @views.issues ?= new Helios.Views.Issues(collection: @issues)
    @views.issues.render()
