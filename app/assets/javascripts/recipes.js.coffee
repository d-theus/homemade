ready = ->
  $('#recipes [name^="delete_recipe_"]').on 'ajax:success', ->
    $(this).closest('.recipe').remove()
  $('#clear_featured_recipes').on 'ajax:success', ->
    alert 'Успешно'
    window.location.reload()

$(document).on 'page:load', ready
$(document).ready ready
