$('form#new_order').submit ->
  $(@).find('.tel').unmask()

NewOrder = $('form#new_order').data('order')
NewOrder.price = null
NewOrder.update = (k,v)->
  console.log "update #{k}: #{v}"
  this[k] = v
  this.refresh()
  console.log this
NewOrder.sync = ->
  console.log "Sync: #{JSON.stringify NewOrder}"
  price_render = $('#price_render')
  price_value =  $('#price_value')
  price_alert =  $('#price_alert')

  price_value
    .queue('fx', (next)->
      price_value.fadeOut()
      next())
    .queue('fx', (next)->
      if Number(NewOrder.price)
        price_alert.addClass('hidden')
        price_render.removeClass('hidden')
        price_value.text(NewOrder.price)
      else
        price_alert.removeClass('hidden')
        price_render.addClass('hidden')
      next())
    .queue('fx', (next)->
      price_value.fadeIn()
      next())
NewOrder.refresh = ->
  if Number(@count) && Number(@servings)
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
  else
    @price = null
  this.sync()
  true
NewOrder.refresh()

$('form#new_order').on 'click', (e)->
  console.log 'input click'
  input = $(e.target).closest('input')
  name = $(input).attr('name') && $(input).attr('name').match(/order\[(.*)\]/)[1]
  if name
    NewOrder.update(name, input.val())

$('form#new_order input option').on 'click', (e)->
  input = $(e.target).closest('input')
  name = $(input).attr('name') && $(input).attr('name').match(/order\[(.*)\]/)[1]
  if name
    NewOrder.update(name, $(@).val())
