reloadWithSuccess = ->
  alert 'Успешно'
  window.location.reload()

showSuccess = ->
  alert 'Успешно'

ready = ->
  $('#recipes [name="delete"]').on 'ajax:success', reloadWithSuccess
  $('#clear_featured_recipes').on 'ajax:success', reloadWithSuccess
  $('#deliver_featured_recipes').on 'ajax:success', showSuccess

$(document).on 'page:load', ready
$(document).ready ready
