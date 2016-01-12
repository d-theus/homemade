wait = (cb)->
  setTimeout ->
    unless $('#count input[type="radio"]').length
      wait()
    else
      cb()
  , 1000

updateCount = (val = Cookies.get('count'))->
  Cookies.set('count', val)
  recipes = $('a[name="recipe"][data-day="4"],a[name="recipe"][data-day="5"]')
  if Number(val) > 3
    recipes.each ->
      $(this).removeClass('fade')
    $('#why_disabled').hide()
  else
    $('#why_disabled').show()
    recipes.each ->
      $(this).addClass('fade')

window.Ui.ready ->
  wait ->
    $('#count input[type="radio"][name="count"]').each ->
      $(this).on 'change', ->
        updateCount($(this).val())
    if cv = Cookies.get('count')
      $('#count input[type="radio"][name="count"][value=' + cv + ']')
        .click()
