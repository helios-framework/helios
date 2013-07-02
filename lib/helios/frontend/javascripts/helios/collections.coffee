class Helios.Collection extends Backbone.Paginator.requestPager
  paginator_ui:
    firstPage: 1,
    currentPage: 1,
    perPage: 20

  server_api:
    'q': ->
      @query || ""
    'limit': ->
      @perPage
    'offset': ->
      (@currentPage - 1) * @perPage

  parse: (response, options) ->
    if _.isArray(response)
      response
    else
      if response.page?
        @total = response.total
        @page = response.page
        @totalPages = Math.ceil(@total / @perPage)

      _.detect response, (value, key) ->
        _.isArray(value)

class Helios.Collections.Entities extends Backbone.Collection
  model: Helios.Models.Entity
  url: '/'

  parse: (response, options) ->
    if _.isArray(response)
      response
    else
      if response.page?
        @total = response.total
        @page = response.page
        @totalPages = Math.ceil(@total / @perPage)

      _.detect response, (value, key) ->
        _.isArray(value)

class Helios.Collections.Resources extends Backbone.Collection
  model: Helios.Models.Resource

  parse: (response, options) ->
    if _.isArray(response)
      response
    else
      if response.page?
        @total = response.total
        @page = response.page
        @totalPages = Math.ceil(@total / @perPage)

      _.detect response, (value, key) ->
        _.isArray(value)

class Helios.Collections.Devices extends Helios.Collection
  model: Helios.Models.Device
  fields: ['token', 'alias', 'badge', 'locale', 'language', 'timezone', 'ip_address', 'lat', 'lng']

  paginator_core:
    type: 'GET'
    dataType: 'json'
    url: '/devices?'

  comparator: (device) ->
    device.get('token')

class Helios.Collections.Receipts extends Helios.Collection
  model: Helios.Models.Receipt

  fields: ['transaction_id', 'product_id', 'purchase_date', 'original_transaction_id', 'original_purchase_date', 'app_item_id', 'version_external_identifier', 'bid', 'bvrs', 'ip_address']

  paginator_core:
    type: 'GET'
    dataType: 'json'
    url: '/receipts?'

class Helios.Collections.Passes extends Helios.Collection
  model: Helios.Models.Pass
  url: '/passes'
  fields: ['pass_type_identifier', 'serial_number', 'authentication_token']

  paginator_core:
    type: 'GET'
    dataType: 'json'
    url: '/passes?'

class Helios.Collections.Issues extends Helios.Collection
  model: Helios.Models.Issue
  url: '/issues'
  fields: ['name', 'title', 'summary', 'published_at', 'expires_at']

  paginator_core:
    type: 'GET'
    dataType: 'json'
    url: '/issues?'
