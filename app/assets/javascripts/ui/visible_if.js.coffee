VisibleIf = {
  init: ->
    this._checked()

  _checked: ->
    str = 'data-visible-if-checked'
    $("[#{str}]:not([#{str}='']").each ->
      subj = $(this)
      cb = $($(this).data("#{str.replace('data-','')}"))
      subj.toggle(cb.is(':checked'))
      cb.on 'change', ->
        subj.slideToggle($(this).is(':checked'))

}

window.Ui.register VisibleIf
