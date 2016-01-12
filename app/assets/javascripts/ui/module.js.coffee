class Module
  constructor: ->
    @elements = []
    @onReady = []

  register: (el)=>
    @elements.push el

  init: =>
    el.init() for el in @elements
    cb() for cb in @onReady

  ready: (cb)=>
    @onReady.push(cb)

window.Ui = new Module()

$(document).on 'page:load', Ui.init
$(document).ready Ui.init
