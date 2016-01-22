reloadWithSuccess = ->
  alert 'Успешно'
  window.location.reload()

ready = ->
  $('#recipes [name="delete"]').on 'ajax:success', reloadWithSuccess
  $('#clear_featured_recipes').on 'ajax:success', reloadWithSuccess

$(document).on 'page:load', ready
$(document).ready ready
