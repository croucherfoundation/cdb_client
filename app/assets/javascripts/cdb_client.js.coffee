jQuery ($) ->
  # tag picker





  # person picker

  $.fn.person_picker_and_editor = ->
    @each ->
      new PersonPickerEditor @
    @

  class PersonPickerEditor
    constructor: (element) ->
      @_container = $(element)
      @_linkage_box = @_container.find('.linkage')
      @_uid_field = @_container.find('[data-role="linker"]')
      @_edit_fields = @_container.find('[data-key]')
      @_cache = {}
      @_people = []
      @_current_person = {}
      @getSuggestionsSoon = _.debounce(@getSuggestions, 500)
      @listenToFields() unless @linked()
      @_linkage_box.find('a.detach').click @defix
      $.ppe = @

    getUid: () =>
      @_uid_field.val()

    linked: () =>
      !!@getUid()

    # get and cache relevant people

    listenToFields: () =>
      @_edit_fields.bind 'keyup', @getSuggestionsSoon
    
    stopListening: () =>
      @_edit_fields.unbind 'keyup', @getSuggestionsSoon

    cacheKey: =>
      @getUid() or @fieldsKey() or "nobody"

    fieldsKey: =>
      key = []
      _.each @_edit_fields, (f) ->
        $f = $(f)
        if val = $f.val()
          key.push $f.data('key') + ":" + val
      key.join(',')

    formData: =>
      formdata = {}
      if person_uid = @getUid()
        formdata["uid"] = person_uid
      _.each @_edit_fields, (f) ->
        $f = $(f)
        if val = $f.val()
          formdata[$f.data("key")] = val
      formdata

    getSuggestions: =>
      # show situation or suggestions
      cache_key = @cacheKey()
      if @_cache[cache_key]
        @showSituation(cache_key)
      else
        @_linkage_box.empty().append($("<p class='waiting'>Checking for matching records.</p>"))
        $.ajax
          method: "GET"
          dataType: "json",
          url: "/cdb/people/suggestions"
          data: 
            person: @formData()
          success: (json) =>
            @cacheJson(cache_key, json)
            @showSituation(cache_key)
          
    cacheJson: (key, json) =>
      @_cache[key] = json
    
    showSituation: (key) =>
      @_people = @_cache[key]
      @_linkage_box.empty()
      if @_person
        statement = $("<p>This record will be linked to <strong>#{@_person.colloquial_name}</strong>, #{@_person.situation}. Changing the fields above will also update the records we hold for #{@_person.formal_name}.</p>")
        warning = $("<p class='danger'></p>")
        detacher = $("<a class='detach'>Detach from #{@_person.formal_name} and reassign</a>").appendTo(warning)
        if @_person.icon
          background = "background-image: url('#{@_person.icon}')"
          mugshot = $("<div class='mugshot' style='#{background}'></div>")
          @_linkage_box.append mugshot
        @_linkage_box.append statement
        @_linkage_box.append warning

      else if @_people?.length
        @_linkage_box.append("<h4>Possible matches:</h4>")
        list = $('<ul class="suggestions"></ul>').appendTo(@_linkage_box)
        _.each @_people, (person) =>
          li = $('<li class="suggestion"></li>').appendTo(list)
          $('<a href="#"><strong>' + person.colloquial_name + '</strong> ' + person.situation + '</a>').appendTo(li).bind 'click', (e) =>
            e.preventDefault()
            @fix(person)
      else 
        @_linkage_box.html("<p>This record is not linked to a person. The fields above will be used to create a new person record. If the input resemble any existing person, links will be suggested here. Please try to link to existing people wherever you can.</p>")

      @_linkage_box.find('a.detach').click @defix



    # attach to and detach from persons
    #
    fix: (person) =>
      e?.preventDefault()
      @_previous_values ?= {}
      @_person = person
      console.log "fix", person
      _.each @_edit_fields, (f) =>
        $f = $(f)
        key = $f.data("key")
        @_previous_values[key] = $f.val()
        $f.val @_person[key]
      @_uid_field.val(@_person.uid)
      @showSituation()
      @stopListening()

    defix: =>
      e?.preventDefault()
      if @_person
        @_previous_values ?= {}
        _.each @_edit_fields, (f) =>
          $f = $(f)
          key = $f.data("key")
          if $f.val() is @_person[key]
            $f.val @_previous_values[key]
        @_uid_field.val('')
        @_person = null
        @getSuggestions()
      else
        @_edit_fields.val('')
        @_uid_field.val('')
        @_person = null
        @showSituation()
      @listenToFields()









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
