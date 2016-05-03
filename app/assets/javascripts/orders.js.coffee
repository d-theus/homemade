$('form#new_order').submit ->
  $(@).find('.tel').unmask()

NewOrder = $('form#new_order').data('order')
NewOrder.price = 0
NewOrder.update = (k,v)->
  console.log "update(#{k}, #{v})"
  this[k] = v
  this.refresh()
NewOrder.sync = ->
  console.log 'sync'
  $('form#new_order [name="price"]')
    .queue('fx', (next)->
      $('form#new_order [name="price"]').fadeOut()
      next())
    .queue('fx', (next)->
      $('form#new_order [name="price"] span').text(NewOrder.price)
      next())
    .queue('fx', (next)->
      $('form#new_order [name="price"]').fadeIn()
      next())
NewOrder.refresh = ->
  console.log 'refresh'
  return unless @count && @servings
  @price = {
    "3":
      {
        "2": 2500
        "3": 3500
        "4": 4500
      }
    "5":
      {
        "2": 3500
        "3": 4500
        "4": 6300
      }
  }[@count][@servings]
  this.sync()
  true
NewOrder.refresh()

$('form#new_order').on 'click', (e)->
  input = $(e.target).closest('input')
  name = $(input).attr('name') && $(input).attr('name').match(/order\[(.*)\]/)[1]
  if name
    console.log input
    console.log name
    NewOrder.update(name, input.val())
