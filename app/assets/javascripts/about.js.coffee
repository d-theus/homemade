ready = ->
  $('a[name="next"]').click ->
    active_slide = $('.overflow-container').find('.slide.in')
    active_slide.removeClass('in')
    next_slide = active_slide.next()
    if next_slide.length
      active_slide.addClass('above')
      active_slide.removeClass('in')
      next_slide.removeClass('below')
      next_slide.addClass('in')
  $('a[name="prev"]').click ->
    active_slide = $('.overflow-container').find('.slide.in')
    prev_slide   = active_slide.prev()
    if prev_slide.length
      active_slide.removeClass('in')
      active_slide.addClass('below')
      prev_slide.addClass('in')
      prev_slide.removeClass('above')

$(document).ready ready
$(document).on 'page:load', ready
