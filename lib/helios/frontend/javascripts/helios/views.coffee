class Helios.Views.Entities extends Backbone.View
  template: JST['data/entities']
  el: "[role='main']"

  events:
    'change #entities': ->
      window.app.navigate(@$el.find("#entities").val(), {trigger: true})

  initialize: ->
    @collection.on 'reset', @render

  render: =>
    @$el.html(@template(entities: @collection))

    @

class Helios.Views.Entity extends Backbone.View
  el: "[role='main']"

  initialize: ->
    @model.on 'reset', @render

    @collection = @model.get('resources')
    @collection.fetch({success: @render})

  render: =>
    if @collection
      @datagrid ?= new Backbone.Datagrid({
        collection: @collection,
        columns: @collection.first().attributes.keys,
        paginated: true,
        perPage: 20
      })
      @$el.find("#datagrid").html(@datagrid.el)

    @

class Helios.Views.Devices extends Backbone.View
  template: JST['push-notification/devices']
  el: "[role='main']"

  events:
    'keyup form.filter input': 'filter'

  initialize: ->
    @datagrid = new Backbone.Datagrid({
      collection: @collection,
      columns: @collection.fields,
      paginated: true,
      perPage: 20
    })

  render: =>
    @$el.html(@template())

    @composeView ?= new Helios.Views.Compose()
    @composeView.render()
    @$el.find("#datagrid").html(@datagrid.el)

    @

  filter: (e) ->
    e.preventDefault()
    @collection.query = $(e.target).val()
    @collection.fetch()

class Helios.Views.Compose extends Backbone.View
  template: JST['push-notification/compose']
  el: "#compose-modal"

  events:
    'submit form': 'submit'
    'click button#send': 'submit'
    'keyup textarea': 'updatePreview'
    'focus textarea': ->
      @$el.find("input[type=radio][value=selected]").prop('checked',true)

  initialize: ->
    window.setInterval(@updateTime, 10000)

  render: ->
    @$el.html(@template())

    @editor = CodeMirror.fromTextArea(document.getElementById("payload"), {
      mode: "application/json",
      theme: "solarized-dark",
      tabMode: "indent",
      lineNumbers : true,
      matchBrackets: true
    })

    @updatePreview()
    @updateTime()

    # $.ajax("/message"
    #   type: "HEAD"

    #   error: (data, status) =>
    #     @disable()
    # )
    @

  submit: ->
    $form = @$el.find("form#compose")
    payload = @editor.getValue()

    tokens = undefined
    if $("input[name='recipients']:checked").val() == "specified"
      tokens = [$form.find("#tokens").val()]

    $.ajax("/message"
      type: "POST"
      dataType: "json"
      data: {
        tokens: tokens,
        payload: payload
      }
    )

      beforeSend: =>
        @$el.find(".alert-error, .alert-success").remove()

      success: (data, status) =>
        alert = """
          <div class="alert alert-block alert-success">
            <button type="button" class="close" data-dismiss="alert">×</button>
            <h4>Push Notification Succeeded</h4>
          </div>
        """
        @$el.prepend(alert)

      error: (data, status) =>
        alert = """
          <div class="alert alert-block alert-error">
            <button type="button" class="close" data-dismiss="alert">×</button>
            <h4>Push Notification Failed</h4>
            <p>#{$.parseJSON(data.responseText).error}</p>
          </div>
        """
        @$el.prepend(alert)


  disable: ->
    alert = """
      <div class="alert alert-block">
        <button type="button" class="close" data-dismiss="alert">×</button>
        <h4>Push Notification Sending Unavailable</h4>
        <p>Check that Rack::PushNotification initializes with a <tt>:certificate</tt> parameter, and that the certificate exists and is readable in the location specified.</p>
      </div>
    """

    @$el.prepend(alert)

    $(".iphone").css(opacity: 0.5)

    $form = @$el.find("form#compose")
    $form.css(opacity: 0.5)
    $form.find("input").disable()

  updatePreview: ->
    try
      json = $.parseJSON(@editor.getValue())
      if alert = json.aps.alert
        $(".preview p").text(alert)

    catch error
      $(".alert strong").text(error.name)
      $(".alert span").text(error.message)
    finally
      if alert? and alert.length > 0
        $(".notification").show()
        $(".alert").hide()
      else
        $(".notification").hide()
        $(".alert").show()

  updateTime: ->
    $time = $("time")
    $time.attr("datetime", Date.now().toISOString())
    $time.find(".time").text(Date.now().toString("HH:mm"))
    $time.find(".date").text(Date.now().toString("dddd, MMMM d"))

class Helios.Views.Receipts extends Backbone.View
  template: JST['in-app-purchase/receipts']
  el: "[role='main']"

  events:
    'keyup form.filter input': 'filter'

  initialize: ->
    @datagrid = new Backbone.Datagrid({
        collection: @collection,
        columns: @collection.fields,
        paginated: true,
        perPage: 20
      })

  render: =>
    @$el.html(@template())
    @$el.find("#datagrid").html(@datagrid.el)

    @

  filter: (e) ->
    e.preventDefault()
    @collection.query = $(e.target).val()
    @collection.fetch()

class Helios.Views.Passes extends Backbone.View
  template: JST['passbook/passes']
  el: "[role='main']"

  events:
    'keyup form.filter input': 'filter'

  initialize: ->
    @datagrid = new Backbone.Datagrid({
        collection: @collection,
        columns: @collection.fields,
        paginated: true,
        perPage: 20
      })

  render: =>
    @$el.html(@template())
    @$el.find("#datagrid").html(@datagrid.el)

    @

  filter: (e) ->
    e.preventDefault()
    @collection.query = $(e.target).val()
    @collection.fetch()

class Helios.Views.Issues extends Backbone.View
  template: JST['newsstand/issues']
  el: "[role='main']"

  events:
    'keyup form.filter input': 'filter'

  initialize: ->
    @datagrid = new Backbone.Datagrid({
        collection: @collection,
        columns: @collection.fields,
        paginated: true,
        perPage: 20
      })

  render: =>
    @$el.html(@template())
    @$el.find("#datagrid").html(@datagrid.el)

    @newView ?= new Helios.Views.NewIssue()
    @newView.render()

    @

  filter: (e) ->
    e.preventDefault()
    @collection.query = $(e.target).val()
    @collection.fetch()

class Helios.Views.NewIssue extends Backbone.View
  template: JST['newsstand/new']
  el: "#new-modal"

  events:
    'submit form': 'submit'
    'click button#create': 'submit'

  render: ->
    @$el.html(@template())

    @

  submit: ->
    $form = @$el.find("form#new")
    $.ajax("/issues"
      type: "POST"
      dataType: "json"
      data: $form.serialize()
    )
