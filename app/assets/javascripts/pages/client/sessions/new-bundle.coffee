$ ->
  signin = ->
    mobile = $("#mobile").val()
    password = $("#password").val()
    if !$.regex.isMobile(mobile)
      $.page_notification("请输入正确的手机号")
      return
    $.postJSON(
      '/client/sessions',
      {
        mobile: mobile
        password: password
      },
      (data) ->
        if data.success
          location.href = "/operator/missions"
        else
          $.page_notification("帐号或密码错误")
      )

  $("#login-btn").click ->
    signin()

  $("#password").keydown (event) ->
    code = event.which
    if code == 13
      signin()
