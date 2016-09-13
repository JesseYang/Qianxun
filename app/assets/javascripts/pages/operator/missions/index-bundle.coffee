$ ->
  $(".do-mission-link").click ->
    company_id = $(this).closest("tr").attr("data-cid")
    console.log(company_id)
    $.postJSON(
      '/operator/missions',
      {
        company_id: company_id
        type: "prospectus"
      },
      (data) ->
        if data.success
          location.href = "/operator/missions/" + data.id + "/edit"
        else
          $.page_notification("服务器出错，请稍后再试")
    )

