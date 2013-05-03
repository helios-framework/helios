class Helios.Routers.Root extends Backbone.Router
  el:
    "div[role='main']"

  initialize: (options) ->
    @views = {}
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
    @views.devices ?= new Helios.Views.Devices(collection: @devices)
    @views.devices.render()

  in_app_purchase: ->
    @receipts ?= new Helios.Collections.Receipts
    @views.receipts ?= new Helios.Views.Receipts(collection: @receipts)
    @views.receipts.render()

  passbook: ->
    @passes ?= new Helios.Collections.Passes
    @views.passes ?= new Helios.Views.Passes(collection: @passes)
    @views.passes.render()

  newsstand: ->
    @issues ?= new Helios.Collections.Issues
    @views.passes ?= new Helios.Views.Issues(collection: @issues)
    @views.passes.render()
