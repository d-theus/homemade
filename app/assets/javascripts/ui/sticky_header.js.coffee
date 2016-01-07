StickyHeader = {
  init: ->
    $(window).scroll this.apply

    $(document).on 'ready', this.apply

  apply: ->
    if $(this).scrollTop() > 1
      $('header.sticky').addClass('in')
    else
      $('header.sticky').removeClass('in')
}

window.Ui.register StickyHeader
