->
  $("li a").click (e) ->
    alert("aaa")
    console.log "clicked"
    e.preventDefault()
    $(this).tab("show")
