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
  buttons = $('button[name="toggle_count"]')
  buttons.on 'click', ->
    val = $(this).val()
    buttons.toggleClass('disabled')
    updateCount(val)

  picture_modal = $('#picture_modal')
  picture_toggles = $('a[data-target="#picture_modal"]')
  picture_toggles.on 'click', ->
    picture_modal.find('img').attr('src', $(this).data('picture'))
