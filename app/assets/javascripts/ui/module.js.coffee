class Module
  constructor: ->
    @elements = []
    @onReady = []

  register: (el)=>
    @elements.push el

  init: =>
    for el in @elements
      try
        el.init()
      catch err
        console.log JSON.stringify(err)
    for cb in @onReady
      try
        cb()
      catch err
        console.log JSON.stringify(err)

  ready: (cb)=>
    @onReady.push(cb)

window.Ui = new Module()

$(document).on 'page:load', Ui.init
$(window).on   'load', Ui.init
