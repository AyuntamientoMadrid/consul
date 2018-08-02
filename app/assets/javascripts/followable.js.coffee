App.Followable =

  update: (followable_id, button, notice) ->
    $("#" + followable_id + " .js-follow").html(button)
    if ($('[data-alert]').length > 0)
      $('[data-alert]').replaceWith(notice)
    else
      $("body").append(notice)
    $('.disable-on-click').bind('ajax:complete', App.Followable.initialize() )

  initialize: ->
    $('.disable-on-click').on 'click', ->
      $(this).attr('disabled', 'disabled')
