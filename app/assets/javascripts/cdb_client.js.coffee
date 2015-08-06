jQuery ($) ->
  # tag picker










  # person picker





  # The institution picker is a simple dropdown box
  # with two special behaviors: if a sibling country box on the same page changes we update the displayed options,
  # and we offer an 'or add one' link that is also (on the server side) country-linked.
  #
  $.fn.institution_picker = ->
    @each ->
      new InstitutionPicker @
    @

  class InstitutionPicker
    constructor: (element) ->
      @_select = $(element)
      @_add = @_select.siblings('input[type="text"]')
      @_toggle = @_select.siblings('a[data-role="toggle"]')
      @_url = @_select.attr('data-url') ? '/cdb/institutions'
      @_alternative = @_select.attr('data-if-none')
      @_select.bind 'refresh', @restrict
      @_cache = {}
      @_request = null
      @_state = 'selecting'
      @_previous_values = []
      @noteValue()
      @_add.attr('placeholder', 'Institution name').disable().hide()
      @_select_text = @_toggle.text()
      @_add_text = @_toggle.attr('data-alt')
      @_select.bind 'change', @noteValue
      @_toggle.bind 'click', @toggle
      if holder = @_select.parents('.institution_chooser').get(0)
        $(holder).find('select[data-role="countrypicker"]').restricts(@_select)
      else
        $('select[data-role="countrypicker"]').restricts(@_select)

    noteValue: (e) =>
      value = @_select.val()
      @_previous_values.push(value)
      if value
        $(@_alternative).slideUp()
      else
        $(@_alternative).slideDown()

    restrict: (e, country_code) =>
      @_select.empty()
      @_request?.abort()
      if data = @_cache[country_code]
        @setOptions(data)
      else
        @_country_code = country_code
        @_select.addClass('waiting')
        @_request = $.getJSON "#{@_url}/#{country_code}", @receive

    receive: (data) =>
      @_cache[@_country_code] = data
      @_select.removeClass('waiting')
      @setOptions(data)

    setOptions: (data) =>
      @_request = null
      if data.length
        @appendOption("", "")
        reselectable = []
        for pair in data
          [name, code] = pair
          @appendOption(name, code)
          reselectable.push(code) if @_previous_values.contains(code)
        @_select.val(reselectable[0] ? "")
        @selectInstead() unless @_state is 'selecting'
      else
        @addInstead()

    appendOption: (name, code) =>
      @_select.append $("<option />").val(code).text(name)

    toggle: (e) =>
      e.preventDefault() if e
      if @_state is 'selecting' then @addInstead() else @selectInstead()
      
    addInstead: () =>
      @_add.enable().show()
      @_select.disable().hide()
      @_toggle.text @_add_text
      @_state = 'adding'

    selectInstead: () =>
      @_select.enable().show()
      @_add.disable().hide()
      @_toggle.text @_select_text
      @_state = 'selecting'




  # The employer picker is a three-way control that can choose an institution, add an institution
  # or show an employer field instead. Like the simpler institution-picker it can be restricted
  # by country.
  #
  $.fn.employer_picker = ->
    @each ->
      new EmployerPicker @
    @

  class EmployerPicker
    constructor: (element) ->
      @_container = $(element)
      
      @_chooser = @_container.find('a[data-role="choose"]')
      @_choose = @_container.find('span[data-role="choose"]')
      @_adder = @_container.find('a[data-role="add"]')
      @_add = @_container.find('span[data-role="add"]')
      @_otherer = @_container.find('a[data-role="other"]')
      @_other = @_container.find('span[data-role="other"]')
      
      @_select = @_choose.find('select')
      @_or = @_container.find('span.or')
      @_url = @_select.attr('data-url') ? '/cdb/institutions'
      @_cache = {}
      @_request = null
      @_state = 'selecting'
      @_previous_values = []

      @_container.find('select[data-role="countrypicker"]').restricts(@_select)
      
      @_select.bind 'refresh', @restrict
      @_select.bind 'change', @noteValue

      @_chooser.bind 'click', @showSelect
      @_adder.bind 'click', @showAdd
      @_otherer.bind 'click', @showOther
      @noteValue()
      
      if @_other.find('input').val()
        @showOther()
      else
        @showSelect()

    noteValue: (e) =>
      value = @_select.val()
      @_previous_values.push(value)
      if value
        $(@_alternative).slideUp()
      else
        $(@_alternative).slideDown()

    restrict: (e, country_code) =>
      @_select.empty()
      @_request?.abort()
      if data = @_cache[country_code]
        @setOptions(data)
      else
        @_country_code = country_code
        @_request = $.getJSON "#{@_url}/#{country_code}", @receive

    receive: (data) =>
      @_cache[@_country_code] = data
      @setOptions(data)

    setOptions: (data) =>
      @_request = null
      if data.length
        @appendOption("", "")
        reselectable = []
        for pair in data
          [name, code] = pair
          @appendOption(name, code)
          reselectable.push(code) if @_previous_values.contains(code) 
        @_select.val(reselectable[0] ? "")
        @showSelect() unless @_state is 'selecting'
      else
        @showAdd()

    appendOption: (name, code) =>
      @_select.append $("<option />").val(code).text(name)

    showAdd: (e) =>
      e.preventDefault() if e
      @_add.enable().show()
      @_adder.hide()
      @_other.disable().hide()
      @_otherer.show()
      @_choose.disable().hide()
      @_chooser.show()
      @_otherer.before @_or

    showSelect: (e) =>
      e.preventDefault() if e
      @_add.disable().hide()
      @_adder.show()
      @_other.disable().hide()
      @_otherer.show()
      @_choose.enable().show()
      @_chooser.hide()
      @_otherer.before @_or

    showOther: (e) =>
      e.preventDefault() if e
      @_add.disable().hide()
      @_adder.show()
      @_other.enable().show()
      @_otherer.hide()
      @_choose.disable().hide()
      @_chooser.show()
      @_adder.before @_or


  $.fn.country_dependent = () ->
    @each ->
      $el = $(@)
      country_select = $el.parents('form').find('select[data-role="countrypicker"]')
      if country_select.length
        toggle = (e) ->
          if country_select.val() is $el.attr('data-country')
            $el.show()
          else
            $el.hide()
        country_select.bind 'change', toggle
        toggle()
