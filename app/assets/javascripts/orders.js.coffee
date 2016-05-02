$('form#new_order').submit ->
  $(@).find('.tel').unmask()

$('form#new_order input').on 'change', ->
  name = $(this).attr('name')
  field = name.match(/order\[(.+)\]/)[1]
  $('form#new_order').data('order')[field] = $(this).val()

