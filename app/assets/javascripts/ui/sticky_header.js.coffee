StickyHeader = {
  self: StickyHeader
  init: ->
    this.apply()

  apply: ->
    header = $('header.sticky')
    header.find('.dropdown').on 'show.bs.dropdown', (e)->
      trigger = e.relatedTarget
      ddm = $(this).find('.dropdown-menu')
      ddm.css('left', $(this).offset().left)

    $(window).scroll this.onScroll
    this.onScroll()

  onScroll: ->
    header = $('header.sticky')
    if $(window).scrollTop() > 1
      header.addClass('in')
    else
      header.removeClass('in')
      header.find('.dropdown').removeClass('open')
      header.find('.navbar-collapse').removeClass('in')
}

window.Ui.register StickyHeader
