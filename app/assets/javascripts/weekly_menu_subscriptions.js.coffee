form = $('#new_weekly_menu_subscription')
success = $('#weekly_menu_subscription_created')
error = $('#weekly_menu_subscription_error')
form.on 'ajax:send', ->
  error.html('')
  error.hide()
form.on 'ajax:success', (response)->
  $(this).hide()
  success.show()
  Cookies.set('weekly_menu_subscribed', true)
form.on 'ajax:error', (e, data)->
  $(this).show()
  json = JSON.parse(data.responseText)
  messages = $('<ul>').appendTo(error)
  json['message'].forEach (msg)->
    li = $("<li>#{msg}</li>")
    console.log li
    messages.append(li)
  error.toggle('true')
