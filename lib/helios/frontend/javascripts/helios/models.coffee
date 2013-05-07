class Helios.Models.Entity extends Backbone.Model
  idAttribute: "name"
  url: ->
    @get('resources').url.replace(/^\//, 'data/')

  parse: (response) ->
    response.resources = new Helios.Collections.Resources()
    response.resources.url = response.url
    response

class Helios.Models.Resource extends Backbone.Model
  idAttribute: "url"

class Helios.Models.Device extends Backbone.Model
  idAttribute: "token"

class Helios.Models.Receipt extends Backbone.Model
  idAttribute: "transaction_id"

class Helios.Models.Pass extends Backbone.Model

class Helios.Models.Issue extends Backbone.Model
  idAttribute: "name"
