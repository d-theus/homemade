updateCount = (val = Cookies.get('count') || 5)->
  Cookies.set('count', val)
  recipes = $('[name="recipe"][data-day="4"],[name="recipe"][data-day="5"]')
  if Number(val) > 3
    recipes.each ->
      $(this).removeClass('fade')
    $('#why_disabled').hide()
  else
    $('#why_disabled').show()
    recipes.each ->
      $(this).addClass('fade')
  $('[name="price"]').toggleClass('hidden')
  $('.order_count input[type="radio"][value=' + val + ']')
    .click()

window.Ui.ready ->
  how = $('#how')
  arrow = $('#how-text-toggle')
  lis = $('#toggle_count li')
  buttons = $('#toggle_count a')
  buttons.on 'click', ->
    val = $(this).data('value')
    lis.removeClass('active')
    $(this).closest('li').addClass('active')
    updateCount(val)
  textToggle = $('#how-text-toggle')
  textToggle.on 'click', ->
    if $('#how').scrollLeft() > 0
      how.animate({scrollLeft: 0}, 300 )
      how.trigger 'scroll'
    else
      how.animate({scrollLeft: $(window).width()}, 300 )
      how.trigger 'scroll'

  # It's better to fix initial state
  how.scrollLeft(0)

  handleHowScroll = ->
    st = $(window).scrollTop()
    hot = how.offset().top
    wh = $(window).height()
    hoh = how.height()
    if (st > (hot - 0.7 * wh)) && (st < (hot + hoh - wh))
      arrow.show()
      arrow.removeClass('out')
      arrow.addClass('in')
    else
      arrow.removeClass('in')
      arrow.addClass('out')

  handleHowLeftScroll = ->
    if how.scrollLeft() > 0
      arrow.removeClass('right')
      arrow.addClass('left')
    else
      arrow.removeClass('left')
      arrow.addClass('right')


  $(window).scroll handleHowScroll
  how.scroll handleHowLeftScroll
