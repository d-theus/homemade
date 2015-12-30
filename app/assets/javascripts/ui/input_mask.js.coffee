InputMask = {
  init: ->
    @_tout = setTimeout =>
      clearTimeout(@_tout)
      if $.fn.mask
        this.apply()
      else
        this.init()
    , 50

  apply: ->
    this._applyPhone()

  _applyPhone: ->
    field = $('input.mask.tel')
    field.mask('+0 (000) 000 00 00')
    field.on 'focus', ->
      if field.val().length == 0
        field.val('+7 (')
      field.focusout ->
        if field.val() == '+7 ('
          field.val('')
}

window.Ui.register InputMask
