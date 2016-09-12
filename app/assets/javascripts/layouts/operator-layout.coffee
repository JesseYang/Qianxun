$ ->
  dropdown = false

  $("#operator-navbar .qx-dropdown-toggle").click (event) ->
    if $(this).hasClass("dropdown-active")
      $(this).removeClass("dropdown-active")
      $("#operator-navbar .qx-dropdown-menu").addClass("hide")
      dropdown = false
    else
      $(this).addClass("dropdown-active")
      $("#operator-navbar .qx-dropdown-menu").removeClass("hide")
      dropdown = true
    false

  $("body").click ->
    if dropdown
      $(".qx-dropdown-toggle").removeClass("dropdown-active")
      $(".qx-dropdown-menu").addClass("hide")
      dropdown = false
    true
