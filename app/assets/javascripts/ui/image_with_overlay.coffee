ImageWithOverlay = {
  init: ->
    this.apply()
    $(window).resize this.apply
  apply: ->
    $('.img-with-overlay').each ->
      img = $(this).find('img')
      if img.length
        $(this).css('background-image', "url(#{img.prop('src')})")
}

window.Ui.register ImageWithOverlay
