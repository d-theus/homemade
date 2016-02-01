MaterialForm = {
  init: ->
    return if navigator.userAgent.match(/(iPod|iPhone|iPad)/)
    @_tout = setTimeout =>
      clearTimeout(@_tout)
      if $.fn.materialForm
        this.apply()
      else
        this.init()
    , 50

  apply: ->
    $('form.material').materialForm()
    $('form.material .material-cb').each ->
      cb = $(this)
      repl = $('<span class="fa material-cb-repl">')
      repl.insertAfter($(this))
      repl.toggleClass('fa-check-square-o', cb.prop('checked'))
      repl.toggleClass('fa-square-o', !cb.prop('checked'))
      repl.on 'click', ->
        cb.trigger 'click'
        repl.toggleClass('fa-check-square-o', cb.prop('checked'))
        repl.toggleClass('fa-square-o', !cb.prop('checked'))
}

window.Ui.register MaterialForm
