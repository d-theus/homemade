ready = ->
  $('a[name="next"]').click ->
    $('.overflow-container').addClass('next')

$(document).ready ready
$(document).on 'page:load', ready
