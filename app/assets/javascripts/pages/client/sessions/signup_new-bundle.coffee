$ ->

  uid = ""
  timer = null
  wait = 60
  mobile = ""
  # verifycode 60 sec reverse 
  time = (o) ->
    console.log wait
    $("#verify-code-btn").attr("disabled", true)
    if wait == 0
      $("#verify-code-btn").attr("disabled", false)
      $("#verify-code-btn").text('获取验证码')
      wait = 60
    else
      $("#verify-code-btn").text('重发(' + wait + ')')
      wait--
      timer = setTimeout (->
        time o
        return
      ), 1000
    return

  $("#verify-code-btn").click ->
    mobile = $("#mobile").val()
    console.log mobile
    if $.regex.isMobile(mobile) == false
      $.page_notification("请输入正确的手机号", 3000)
      return
    $.postJSON(
      '/client/sessions/signup',
      {
        mobile: mobile
      },
      (data) ->
        console.log data
        if data.success
          uid = data.uid
          console.log uid
          if timer != null
            clearTimeout(timer)
          time()
        else
          $.page_notification("手机号已存在，请直接登录")
    )


  signup = ->
    if uid == ""
      return
    password = $("#password").val().trim()
    verify_code = $("#verify_code").val().trim()

    if password.length < 6
      $.page_notification("密码长度不得小于六位")
      return

    if verify_code == ""
      $.page_notification("请输入验证码")
      return
    
    $.postJSON(
      '/client/sessions/' + uid + '/verify',
      {
        password: password
        verify_code: verify_code
      },
      (data) ->
        if data.success
          $.page_notification("注册成功，正在跳转")
          window.location.href = "/client/sessions/new?flash=注册成功，请登录&mobile=" + mobile
        else
          $.page_notification("验证码错误")
          $("#verify_code").focus()
      )

  $("#verify-btn").click ->
    signup()

  $("#password").keydown (event) ->
    code = event.which
    if code == 13
      signup()