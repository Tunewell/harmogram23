window.Sounder =
  Models: {}
  Collections: {}
  Views: {}
  Routers: {}

  init: ->
    # Initialize Routers
    @Routers.main = new Sounder.Routers.Main()
    Backbone.history.start()


$ ->
  Sounder.init()
