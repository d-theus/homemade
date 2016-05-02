updateCount = (val = Cookies.get('count') || 5)->
  Cookies.set('count', val)
  recipes = $('[name="recipe"][data-day="4"],[name="recipe"][data-day="5"]')
  if Number(val) > 3
    recipes.removeClass('fade')
    $('#why_disabled').hide()
  else
    $('#why_disabled').show()
    recipes.addClass('fade')
  $(".order_count input[type=\"radio\"][value=\"#{val}\"]").click()

notifyUnpaid = ->
  $('#unpaid_modal').modal('show')

getThursday = ->
  today = new Date()
  td = today.getDay()
  offset = if td < 5 then 4 - td else 11 - td
  new Date(today.getFullYear(), today.getMonth(), today.getDate() + offset, 23, 59)


window.Ui.ready ->
  how = $('#how')
  arrow = $('#how-text-toggle')
  count_lis = $('#toggle_count li')
  count_buttons = $('#toggle_count a')
  order_modal = $('#order_modal')
  order_modal_shown = false
  order_modal.on 'shown.bs.modal', ->
    unless order_modal_shown
      ga('send', 'event', 'order', 'shown', 'modal')
      yaCounter35600140.reachGoal('order_clicked')
      order_modal_shown = true
  count_buttons.on 'click', ->
    unless $(this).closest('li').hasClass('active')
      count_lis.removeClass('active')
      $(this).closest('li').addClass('active')
      count = $(this).data('count')
      updateCount(count)

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
        Cookies.set('ignore_orders', JSON.stringify(ios), expires: getThursday())
      else
        Cookies.set('ignore_orders', JSON.stringify([id]), expires: getThursday())

