App.Forms =

  disableEnter: ->
    $('form.js-enter-disabled').on('keyup keypress', (event) ->
      if event.which == 13
        e.preventDefault()
    )

  submitOnChange: ->
    $('.js-submit-on-change').unbind('change').on('change', ->
      $(this).closest('form').submit()
      false
    )

  toggleLink: ->
    $('.js-toggle-link').unbind('click').on('click', ->
      $($(this).data('toggle-selector')).toggle("down")
      if $(this).data('toggle-text') isnt undefined
        toggle_txt = $(this).text()
        $(this).text( $(this).data('toggle-text')  )
        $(this).data('toggle-text', toggle_txt)

      false
    )

  synchronizeInputs: ->
    $("[name='progress_bar[percentage]']").on
      input: ->
        $("[name='#{this.name}']").val($(this).val())

    $("[name='progress_bar[percentage]'][type='range']").trigger("input")

  hideOrShowFieldsAfterSelection: ->
    $("[name='progress_bar[kind]']").on
      change: ->
        title_field = $("[name^='progress_bar'][name$='[title]']").parent()

        if this.value == "primary"
          title_field.hide()
          $("#globalize_locales").hide()
        else
          title_field.show()
          $("#globalize_locales").show()

    $("[name='progress_bar[kind]']").change()

  toggleSelect: ->
    $('.js-toggle-select').on('change', ->
      dropdown = $(this)
      target = $(dropdown.data('toggle-selector'))

      if dropdown.val() in dropdown.data('hide-on').split(',')
        target.addClass('hide')
      else
        target.removeClass('hide')
    )

  initialize: ->
    App.Forms.disableEnter()
    App.Forms.submitOnChange()
    App.Forms.toggleLink()
    App.Forms.synchronizeInputs()
    App.Forms.hideOrShowFieldsAfterSelection()
    App.Forms.toggleSelect()
    false
