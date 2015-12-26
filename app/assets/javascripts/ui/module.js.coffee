class Module
  constructor: ->
    @elements = []

  register: (el)=>
    @elements.push el

  init: =>
    el.init() for el in @elements


window.Ui = new Module()

$(document).on 'page:load', Ui.init
$(document).ready Ui.init
