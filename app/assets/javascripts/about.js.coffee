ready = ->
  #$(window).scroll ->
    #unless  $(window).scrollTop() > $('#summary').height()
      #$('#summary .bg img').css('top', $(window).scrollTop())

    #$('#pros .bg img').css('top', $(window).scrollTop())

$(document).ready ready
$(document).on 'page:load', ready
