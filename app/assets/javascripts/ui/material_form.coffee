MaterialForm = {
  init: ->
    @_tout = setTimeout =>
      clearTimeout(@_tout)
      if $.fn.materialForm
        $('form.material').materialForm()
      else
        this.init()
    , 50
}

window.Ui.register MaterialForm
