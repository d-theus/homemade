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

notifyUnpaid = ->
  $('#unpaid_modal').modal('show')

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
      how.animate({scrollLeft: 1.2 * $(window).width()}, 300 )
      how.trigger 'scroll'


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

  # It's better to fix initial state
  how.scrollLeft(0)
  how.trigger('scroll')

  if (n = Number(Cookies.get('last_order'))) > 0
    if ios_j = Cookies.get('ignore_orders')
      ios = JSON.parse(ios_j)
      if ios.indexOf(n) < 0
        notifyUnpaid()
    else
      notifyUnpaid()

  $('#unpaid_modal').on 'hidden.bs.modal', ->
    cb = $('#unpaid_modal [name="ignore_order"]')
    console.log cb
    console.log cb.prop('checked')
    if cb.prop('checked')
      id = Number cb.data('id')
      console.log id
      if ioss = Cookies.get('ignore_orders')
        ios = JSON.parse ioss
        ios.push(id)
        Cookies.set('ignore_orders', JSON.stringify(ios))
      else
        Cookies.set('ignore_orders', JSON.stringify([id]))
