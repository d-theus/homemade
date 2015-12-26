StickyHeader = {
  init: ->
    $(window).scroll this.apply

    $(document).on 'ready', this.apply

  apply: ->
    if $(this).scrollTop() > 1
      $('header').addClass('in')
    else
      $('header').removeClass('in')
}

window.Ui.register StickyHeader
