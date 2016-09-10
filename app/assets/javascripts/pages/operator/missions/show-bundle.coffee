#= require wangEditor.min

$ ->

  main_business_editor = new wangEditor('main-business-editor')
  main_business_editor.config.menus = [
        'head',
        'img'
     ]
  main_business_editor.config.uploadImgUrl = '/materials'
  main_business_editor.config.uploadHeaders = {
    'Accept' : 'HTML'
  }
  main_business_editor.config.hideLinkImg = true
  main_business_editor.create()

  market_space_editor = new wangEditor('market-space-editor')
  market_space_editor.config.menus = [
        'head',
        'img'
     ]
  market_space_editor.config.uploadImgUrl = '/materials'
  market_space_editor.config.uploadHeaders = {
    'Accept' : 'HTML'
  }
  market_space_editor.config.hideLinkImg = true
  market_space_editor.create()

  $(document).on(
    "click",
    ".rm-risk",
    ->
      $(this).closest(".risk-wrapper").remove()
  )
  $(".add-risk").click ->
    $(".risks-wrapper").append($(".risk-clone").children(":first").clone())

  $(document).on(
    "click",
    ".rm-business-mode",
    ->
      $(this).closest(".business-mode-wrapper").remove()
  )
  $(".add-business-mode").click ->
    $(".business-modes-wrapper").append($(".business-mode-clone").children(":first").clone())

  $(document).on(
    "click",
    ".rm-rival",
    ->
      $(this).closest(".rival-wrapper").remove()
  )
  $(".add-rival").click ->
    $(".rivals-wrapper").append($(".rival-clone").children(":first").clone())

