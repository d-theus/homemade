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
  lis = $('#toggle_count li')
  buttons = $('#toggle_count a')
  buttons.on 'click', ->
    val = $(this).data('value')
    lis.removeClass('active')
    $(this).closest('li').addClass('active')
    updateCount(val)
