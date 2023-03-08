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
      @_linkage_box.find('a.detach').click @defix
      unless @linked()
        @listenToFields()
        @getSuggestions()
      $.pp = @

    getUid: () =>
      @_uid_field.val()

    linked: () =>
      !!@getUid()

    populated: () =>
      populated_fields = @_edit_fields.filter -> !!@value
      populated_fields.length > 0

    # get and cache relevant people

    listenToFields: () =>
      @_edit_fields.bind 'keyup', @getSuggestionsSoon
    
    stopListening: () =>
      @_edit_fields.unbind 'keyup', @getSuggestionsSoons

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
        if @populated()
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
        linkee = $('<div class="linkee"></div>')
        statement = $("<p>This record will be linked to <strong>#{@_person.colloquial_name}</strong>, #{@_person.situation}. Changing the fields above will also update the records we hold for #{@_person.formal_name}.</p>").appendTo(linkee)
        warning = $("<p class='danger'></p>").appendTo(linkee)
        detacher = $("<a class='detach'>Detach from #{@_person.formal_name} and reassign</a>").appendTo(warning)
        if @_person.thumb
          mugshot = $("<div class='mugshot' style='background-image: url(#{@_person.thumb})'></div>")
          @_linkage_box.append mugshot
        @_linkage_box.append linkee

      else if @_people?.length
        @_linkage_box.append("<h4>Possible matches:</h4>")
        list = $('<ul class="suggestions"></ul>').appendTo(@_linkage_box)
        _.each @_people, (person) =>
          li = $('<li class="suggestion"></li>').appendTo(list)
          $('<a href="#"><strong>' + person.colloquial_name + '</strong> ' + person.situation + '</a>').appendTo(li).bind 'click', (e) =>
            e.preventDefault()
            @fix(person)
      else 
        @_linkage_box.html("<div class=\"linkee\"><p>This record is not linked to a person. The fields above will be used to create a new person record. If the input resemble any existing person, links will be suggested here. Please try to link to existing people wherever you can.</p></div>")

      @_linkage_box.find('a.detach').click @defix

    # attach to and detach from persons
    #
    fix: (person) =>
      e?.preventDefault()
      @_previous_values ?= {}
      @_person = person
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


  # The institution or employer picker is a compound control that supports the usual logic of
  # institution-in-country or employer-with-address.
  #
  $.fn.institution_or_employer = ->
    @each ->
      new InstitutionOrEmployer @
    @

  class InstitutionOrEmployer
    constructor: (element) ->
      @_container = $(element)
      @_cache = {}
      @_previous_values = []

      @_country_chooser = @_container.find('[data-role="country"]')
      @_chooser = @_container.find('[data-role="showchoose"]')
      @_choose = @_container.find('[data-role="choose"]')
      @_adder = @_container.find('[data-role="showadd"]')
      @_add = @_container.find('[data-role="add"]')
      @_otherer = @_container.find('[data-role="showother"]')
      @_other = @_container.find('[data-role="other"]')
      @_select = @_choose.find('select')
      @_or = @_container.find('span.or')
      @_url = @_select.attr('data-url') ? '/cdb/institutions'

      @_select.bind 'refresh', @restrict
      @_select.bind 'change', @noteValue
      @_country_chooser.restricts(@_select)

      @_chooser.bind 'click', @showSelect
      @_adder.bind 'click', @showAdd
      @_otherer.bind 'click', @showOther
      @noteValue()
      @removeInstitutionOption()

      if @_other.find('input').val()
        @showOther()
      else
        @showSelect()

    removeInstitutionOption: (e) =>
      if @_country_chooser.find(":selected").text() == 'Hong Kong'
        @_adder.hide()
      $("#application_institution_code option[value='open-hong-kong']").hide();
      $("#application_institution_code option[value='hospital-authority']").hide();

    noteValue: (e) =>
      value = @_select.val()
      @_previous_values.push(value)

    restrict: (e, country_code) =>
      if country_code == 'HKG'
        @_adder.hide()
      else
        @_adder.show()
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
        institution_suggest_selection = $('.institution_suggest_selection')
        if institution_suggest_selection && institution_suggest_selection.next('.dropdown')
         institution_suggest_selection.next('.dropdown').empty()
        reselectable = []
        for pair in data
          [name, code] = pair
          if name != 'Hospital Authority' && name != 'Open University of Hong Kong'
            @appendOption(name, code)
          reselectable.push(code) if @_previous_values.contains(code)
        @_select.val(reselectable[0] ? "")
        @showSelect()
      else
        @showAdd()

    appendOption: (name, code) =>
      @_select.append $("<option />").val(code).text(name)

    showAdd: (e) =>
      e?.preventDefault()
      if @_country_chooser.find(":selected").text() != 'Hong Kong'
        @_other.find('input').val("")
        @_choose.find('select').val("")
        @_add.enable().show()
        @_adder.hide()
        @_other.hide()
        @_otherer.show()
        @_choose.hide()
        @_chooser.show()
        @_otherer.before @_or

    showSelect: (e) =>
      e?.preventDefault()
      @_other.find('input').val("")
      @_add.find('input').val("")
      @_add.hide()
      if @_country_chooser.find(":selected").text() != 'Hong Kong'
        @_adder.show()
      @_other.hide()
      @_otherer.show()
      @_choose.enable().show()
      @_chooser.hide()
      @_otherer.before @_or

    showOther: (e) =>
      e?.preventDefault()
      @_add.find('input').val("")
      @_choose.find('select').val("")
      @_add.hide()
      if @_country_chooser.find(":selected").text() != 'Hong Kong'
        @_adder.show()
      @_other.enable().show()
      @_otherer.hide()
      @_choose.hide()
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
