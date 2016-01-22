wait = (cb)->
  setTimeout ->
    unless $('#count input[type="radio"]').length
      wait()
    else
      cb()
  , 1000

updateCount = (val = Cookies.get('count') || 5)->
  Cookies.set('count', val)
  recipes = $('[name="recipe"][data-day="4"],[name="recipe"][data-day="5"]')
  if Number(val) > 3
    recipes.each ->
      $(this).removeClass('fade')
    $('#why_disabled').hide()
    $('#price_5').show()
    $('#price_3').hide()
  else
    $('#why_disabled').show()
    $('#price_5').hide()
    $('#price_3').show()
    recipes.each ->
      $(this).addClass('fade')
  $('.order_count input[type="radio"][value=' + val + ']')
    .click()

window.Ui.ready ->
  wait ->
    updateCount()
    $('#count input[type="radio"][name="count"]').each ->
      $(this).on 'change', ->
        updateCount($(this).val())
    if cv = Cookies.get('count')
      $('#count input[type="radio"][name="count"][value=' + cv + ']')
        .click()
      $('.order_count input[type="radio"][value=' + cv + ']')
        .click()
