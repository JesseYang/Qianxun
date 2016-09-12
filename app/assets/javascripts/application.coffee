# This is a manifest file that'll be compiled into application.js, which will include all the files
# listed below.
#
# Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
# or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
#
# It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
# compiled file.
#
# Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
# about supported directives.
#
#= require jquery
#= require jquery-ui
#= require jquery_ujs
#= require utility/ajax
#= require utility/console
#= require utility/regex
#= require utility/err_code
#= require handlebars.runtime
#= require jquery-migrate-1.2.1.min
#= require bootstrap-sprockets
#= require ui/widgets/notification
#= require extensions/page_notification

$ ->
  if $.browser.msie && parseFloat($.browser.version) < 8
    setTimeout ->
      $('#browser').slideDown()
    , 500
  else
    $('#browser').remove();

  $.page_notification window.flash

  Handlebars.registerHelper "ifCond", (v1, v2, options) ->
    return options.fn(this)  if v1 is v2
    options.inverse this

  Handlebars.registerHelper "ifCondNot", (v1, v2, options) ->
    return options.fn(this)  if v1 is not v2
    options.inverse this
