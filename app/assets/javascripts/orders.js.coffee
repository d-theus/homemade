$('form#new_order').submit ->
  $(@).find('.tel').unmask()
