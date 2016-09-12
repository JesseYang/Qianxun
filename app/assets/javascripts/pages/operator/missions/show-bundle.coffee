#= require wangEditor.min

$ ->

  create_editor = (dom_id) ->
    editor = new wangEditor(dom_id)
    editor.config.menus = ['head', 'img', 'table']
    editor.config.uploadImgUrl = '/materials'
    editor.config.uploadHeaders = {'Accept' : 'HTML'}
    editor.config.hideLinkImg = true
    editor.create()
    return editor

  main_business_editor = create_editor('main-business-editor')
  market_space_editor = create_editor('market-space-editor')
  advantage_editor = create_editor('advantage-editor')
  disadvantage_editor = create_editor('disadvantage-editor')
  strategy_editor = create_editor('strategy-editor')
  solvency_editor = create_editor('solvency-editor')
  operation_ability_editor = create_editor('operation-ability-editor')
  cash_flow_editor = create_editor('cash-flow-editor')

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

  update_year = (dom) ->
    base_year = parseInt($(dom).val())
    i = 0
    $(dom).closest(".block-wrapper").find(".nav-tabs").children().each ->
      $(this).find("a").text((base_year - i) + "年度")
      i = i + 1

  $(".base-year").change ->
    update_year(this)

  $(".base-year").each ->
    update_year(this)

  $(".submit-btn").click ->
    risks = [ ]
    $(".risks-wrapper").children().each ->
      risk = {
        name: $(this).find(".risk-name").val()
        desc: $(this).find(".risk-desc").val()
        type: $(this).find(".risk-type").val()
      }
      if risk["name"] != ""
        risks.push(risk)

    main_business = main_business_editor.$txt.html()

    main_customer_base_year = parseInt($(".main-customer-base-wrapper .base-year").val())
    years = [main_customer_base_year + "", main_customer_base_year - 1 + "", main_customer_base_year - 2 + ""]
    main_customers = { }
    main_customers[years[0]] = [ ]
    main_customers[years[1]] = [ ]
    main_customers[years[2]] = [ ]
    $.each(
      ["#main-customer-tab-1", "#main-customer-tab-2", "#main-customer-tab-3"],
      (i, tab) ->
        $(tab).children().each ->
          main_customer = {
            name: $(this).find(".customer-name").val()
            value: $(this).find(".customer-value").val()
            ratio: $(this).find(".customer-ratio").val()
          }
          if main_customer["name"] != ""
            main_customers[years[i]].push(main_customer)
      )

    main_dealer_base_year = parseInt($(".main-dealer-base-wrapper .base-year").val())
    years = [main_dealer_base_year + "", main_dealer_base_year - 1 + "", main_dealer_base_year - 2 + ""]
    main_dealers = { }
    main_dealers[years[0]] = [ ]
    main_dealers[years[1]] = [ ]
    main_dealers[years[2]] = [ ]
    $.each(
      ["#main-dealer-tab-1", "#main-dealer-tab-2", "#main-dealer-tab-3"],
      (i, tab) ->
        $(tab).children().each ->
          main_dealer = {
            name: $(this).find(".dealer-name").val()
            value: $(this).find(".dealer-value").val()
            ratio: $(this).find(".dealer-ratio").val()
          }
          if main_dealer["name"] != ""
            main_dealers[years[i]].push(main_dealer)
      )

    main_provider_base_year = parseInt($(".main-provider-base-wrapper .base-year").val())
    years = [main_provider_base_year + "", main_provider_base_year - 1 + "", main_provider_base_year - 2 + ""]
    main_providers = { }
    main_providers[years[0]] = [ ]
    main_providers[years[1]] = [ ]
    main_providers[years[2]] = [ ]
    $.each(
      ["#main-provider-tab-1", "#main-provider-tab-2", "#main-provider-tab-3"],
      (i, tab) ->
        $(tab).children().each ->
          main_provider = {
            name: $(this).find(".provider-name").val()
            value: $(this).find(".provider-value").val()
            ratio: $(this).find(".provider-ratio").val()
          }
          if main_provider["name"] != ""
            main_providers[years[i]].push(main_provider)
      )

    business_modes = [ ]
    $(".business-modes-wrapper").children().each ->
      business_mode = {
        type: $(this).find(".business-mode-type").val()
        desc: $(this).find(".business-mode-desc").val()
      }
      if business_mode["type"] != "-1"
        business_modes.push(business_mode)

    market_space = market_space_editor.$txt.html()

    rivals = [ ]
    $(".rivals-wrapper").children().each ->
      rival = {
        brand: $(this).find(".rival-brand").val()
        name: $(this).find(".rival-name").val()
        introduce: $(this).find(".rival-introduce").val()
        desc: $(this).find(".rival-desc").val()
      }
      if rival["brand"] != "" || rival["name"] != ""
        rivals.push(rival)

    advantage = advantage_editor.$txt.html()

    disadvantage = disadvantage_editor.$txt.html()

    strategy = strategy_editor.$txt.html()

    solvency = solvency_editor.$txt.html()

    operation_ability = operation_ability_editor.$txt.html()

    cash_flow = cash_flow_editor.$txt.html()

    $.putJSON(
      '/operator/missions/' + window.mid,
      prospectus: {
        risks: risks
        main_business: main_business
        main_customers: main_customers
        main_dealers: main_dealers
        main_providers: main_providers
        business_modes: business_modes
        market_space: market_space
        rivals: rivals
        advantage: advantage
        disadvantage: disadvantage
        strategy: strategy
        solvency: solvency
        operation_ability: operation_ability
        cash_flow: cash_flow
      },
      (data) ->
        $.page_notification("数据已更新")
      )


  $(".default-hide").hide()
  $(".toggle-link").click ->
    if $(this).hasClass("is_hidden")
      $(this).parent().next().slideDown()
      $(this).text("收起")
      $(this).removeClass("is_hidden")
    else
      $(this).parent().next().slideUp()
      $(this).text("展开")
      $(this).addClass("is_hidden")
