ready = ->
  $('#recipes [name^="delete_recipe_"]').on 'ajax:success', ->
    $(this).closest('.recipe').remove()

$(document).on 'page:load', ready
$(document).ready ready
