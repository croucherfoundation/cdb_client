(function() {
  var bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  jQuery(function($) {
    var InstitutionOrEmployer, PersonPickerEditor;
    $.fn.person_picker_and_editor = function() {
      this.each(function() {
        return new PersonPickerEditor(this);
      });
      return this;
    };
    PersonPickerEditor = (function() {
      function PersonPickerEditor(element) {
        this.defix = bind(this.defix, this);
        this.fix = bind(this.fix, this);
        this.showSituation = bind(this.showSituation, this);
        this.cacheJson = bind(this.cacheJson, this);
        this.getSuggestions = bind(this.getSuggestions, this);
        this.formData = bind(this.formData, this);
        this.fieldsKey = bind(this.fieldsKey, this);
        this.cacheKey = bind(this.cacheKey, this);
        this.stopListening = bind(this.stopListening, this);
        this.listenToFields = bind(this.listenToFields, this);
        this.populated = bind(this.populated, this);
        this.linked = bind(this.linked, this);
        this.getUid = bind(this.getUid, this);
        this._container = $(element);
        this._linkage_box = this._container.find('.linkage');
        this._uid_field = this._container.find('[data-role="linker"]');
        this._edit_fields = this._container.find('[data-key]');
        this._cache = {};
        this._people = [];
        this._current_person = {};
        this.getSuggestionsSoon = _.debounce(this.getSuggestions, 500);
        this._linkage_box.find('a.detach').click(this.defix);
        if (!this.linked()) {
          this.listenToFields();
          this.getSuggestions();
        }
        $.pp = this;
      }

      PersonPickerEditor.prototype.getUid = function() {
        return this._uid_field.val();
      };

      PersonPickerEditor.prototype.linked = function() {
        return !!this.getUid();
      };

      PersonPickerEditor.prototype.populated = function() {
        var populated_fields;
        populated_fields = this._edit_fields.filter(function() {
          return !!this.value;
        });
        return populated_fields.length > 0;
      };

      PersonPickerEditor.prototype.listenToFields = function() {
        return this._edit_fields.bind('keyup', this.getSuggestionsSoon);
      };

      PersonPickerEditor.prototype.stopListening = function() {
        return this._edit_fields.unbind('keyup', this.getSuggestionsSoons);
      };

      PersonPickerEditor.prototype.cacheKey = function() {
        return this.getUid() || this.fieldsKey() || "nobody";
      };

      PersonPickerEditor.prototype.fieldsKey = function() {
        var key;
        key = [];
        _.each(this._edit_fields, function(f) {
          var $f, val;
          $f = $(f);
          if (val = $f.val()) {
            return key.push($f.data('key') + ":" + val);
          }
        });
        return key.join(',');
      };

      PersonPickerEditor.prototype.formData = function() {
        var formdata, person_uid;
        formdata = {};
        if (person_uid = this.getUid()) {
          formdata["uid"] = person_uid;
        }
        _.each(this._edit_fields, function(f) {
          var $f, val;
          $f = $(f);
          if (val = $f.val()) {
            return formdata[$f.data("key")] = val;
          }
        });
        return formdata;
      };

      PersonPickerEditor.prototype.getSuggestions = function() {
        var cache_key;
        cache_key = this.cacheKey();
        if (this._cache[cache_key]) {
          return this.showSituation(cache_key);
        } else {
          if (this.populated()) {
            this._linkage_box.empty().append($("<p class='waiting'>Checking for matching records.</p>"));
            return $.ajax({
              method: "GET",
              dataType: "json",
              url: "/cdb/people/suggestions",
              data: {
                person: this.formData()
              },
              success: (function(_this) {
                return function(json) {
                  _this.cacheJson(cache_key, json);
                  return _this.showSituation(cache_key);
                };
              })(this)
            });
          }
        }
      };

      PersonPickerEditor.prototype.cacheJson = function(key, json) {
        return this._cache[key] = json;
      };

      PersonPickerEditor.prototype.showSituation = function(key) {
        var detacher, linkee, list, mugshot, ref, statement, warning;
        this._people = this._cache[key];
        this._linkage_box.empty();
        if (this._person) {
          linkee = $('<div class="linkee"></div>');
          statement = $("<p>This record will be linked to <strong>" + this._person.colloquial_name + "</strong>, " + this._person.situation + ". Changing the fields above will also update the records we hold for " + this._person.formal_name + ".</p>").appendTo(linkee);
          warning = $("<p class='danger'></p>").appendTo(linkee);
          detacher = $("<a class='detach'>Detach from " + this._person.formal_name + " and reassign</a>").appendTo(warning);
          if (this._person.thumb) {
            mugshot = $("<div class='mugshot' style='background-image: url(" + this._person.thumb + ")'></div>");
            this._linkage_box.append(mugshot);
          }
          this._linkage_box.append(linkee);
        } else if ((ref = this._people) != null ? ref.length : void 0) {
          this._linkage_box.append("<h4>Possible matches:</h4>");
          list = $('<ul class="suggestions"></ul>').appendTo(this._linkage_box);
          _.each(this._people, (function(_this) {
            return function(person) {
              var li;
              li = $('<li class="suggestion"></li>').appendTo(list);
              return $('<a href="#"><strong>' + person.colloquial_name + '</strong> ' + person.situation + '</a>').appendTo(li).bind('click', function(e) {
                e.preventDefault();
                return _this.fix(person);
              });
            };
          })(this));
        } else {
          this._linkage_box.html("<div class=\"linkee\"><p>This record is not linked to a person. The fields above will be used to create a new person record. If the input resemble any existing person, links will be suggested here. Please try to link to existing people wherever you can.</p></div>");
        }
        return this._linkage_box.find('a.detach').click(this.defix);
      };

      PersonPickerEditor.prototype.fix = function(person) {
        if (typeof e !== "undefined" && e !== null) {
          e.preventDefault();
        }
        if (this._previous_values == null) {
          this._previous_values = {};
        }
        this._person = person;
        _.each(this._edit_fields, (function(_this) {
          return function(f) {
            var $f, key;
            $f = $(f);
            key = $f.data("key");
            _this._previous_values[key] = $f.val();
            return $f.val(_this._person[key]);
          };
        })(this));
        this._uid_field.val(this._person.uid);
        this.showSituation();
        return this.stopListening();
      };

      PersonPickerEditor.prototype.defix = function() {
        if (typeof e !== "undefined" && e !== null) {
          e.preventDefault();
        }
        if (this._person) {
          if (this._previous_values == null) {
            this._previous_values = {};
          }
          _.each(this._edit_fields, (function(_this) {
            return function(f) {
              var $f, key;
              $f = $(f);
              key = $f.data("key");
              if ($f.val() === _this._person[key]) {
                return $f.val(_this._previous_values[key]);
              }
            };
          })(this));
          this._uid_field.val('');
          this._person = null;
          this.getSuggestions();
        } else {
          this._edit_fields.val('');
          this._uid_field.val('');
          this._person = null;
          this.showSituation();
        }
        return this.listenToFields();
      };

      return PersonPickerEditor;

    })();
    $.fn.institution_or_employer = function() {
      this.each(function() {
        return new InstitutionOrEmployer(this);
      });
      return this;
    };
    InstitutionOrEmployer = (function() {
      function InstitutionOrEmployer(element) {
        this.showOther = bind(this.showOther, this);
        this.showSelect = bind(this.showSelect, this);
        this.showAdd = bind(this.showAdd, this);
        this.appendOption = bind(this.appendOption, this);
        this.setOptions = bind(this.setOptions, this);
        this.receive = bind(this.receive, this);
        this.restrict = bind(this.restrict, this);
        this.noteValue = bind(this.noteValue, this);
        this.removeInstitutionOption = bind(this.removeInstitutionOption, this);
        var ref;
        this._container = $(element);
        this._cache = {};
        this._previous_values = [];
        this._country_chooser = this._container.find('[data-role="country"]');
        this._chooser = this._container.find('[data-role="showchoose"]');
        this._choose = this._container.find('[data-role="choose"]');
        this._adder = this._container.find('[data-role="showadd"]');
        this._add = this._container.find('[data-role="add"]');
        this._otherer = this._container.find('[data-role="showother"]');
        this._other = this._container.find('[data-role="other"]');
        this._select = this._choose.find('select');
        this._or = this._container.find('span.or');
        this._url = (ref = this._select.attr('data-url')) != null ? ref : '/cdb/institutions';
        this._select.bind('refresh', this.restrict);
        this._select.bind('change', this.noteValue);
        this._country_chooser.restricts(this._select);
        this._chooser.bind('click', this.showSelect);
        this._adder.bind('click', this.showAdd);
        this._otherer.bind('click', this.showOther);
        this.noteValue();
        this.removeInstitutionOption();
        if (this._other.find('input').val()) {
          this.showOther();
        } else {
          this.showSelect();
        }
      }

      InstitutionOrEmployer.prototype.removeInstitutionOption = function(e) {
        if (this._country_chooser.find(":selected").text() === 'Hong Kong') {
          this._or.hide();
          this._adder.hide();
        }
        $("#application_institution_code option[value='open-hong-kong']").hide();
        return $("#application_institution_code option[value='hospital-authority']").hide();
      };

      InstitutionOrEmployer.prototype.noteValue = function(e) {
        var value;
        value = this._select.val();
        return this._previous_values.push(value);
      };

      InstitutionOrEmployer.prototype.restrict = function(e, country_code) {
        var data, ref;
        if (country_code === 'HKG') {
          this._adder.hide();
          this._or.hide();
        } else {
          this._adder.show();
          this._or.show();
        }
        this._select.empty();
        if ((ref = this._request) != null) {
          ref.abort();
        }
        if (data = this._cache[country_code]) {
          return this.setOptions(data);
        } else {
          this._country_code = country_code;
          this._select.addClass('waiting');
          return this._request = $.getJSON(this._url + "/" + country_code, this.receive);
        }
      };

      InstitutionOrEmployer.prototype.receive = function(data) {
        this._cache[this._country_code] = data;
        this._select.removeClass('waiting');
        return this.setOptions(data);
      };

      InstitutionOrEmployer.prototype.setOptions = function(data) {
        var code, i, institution_suggest_selection, len, name, pair, ref, reselectable;
        this._request = null;
        if (data.length) {
          this.appendOption("", "");
          institution_suggest_selection = $('.institution_suggest_selection');
          if (institution_suggest_selection && institution_suggest_selection.next('.dropdown')) {
            institution_suggest_selection.next('.dropdown').empty();
          }
          reselectable = [];
          for (i = 0, len = data.length; i < len; i++) {
            pair = data[i];
            name = pair[0], code = pair[1];
            if (name !== 'Hospital Authority' && name !== 'Open University of Hong Kong') {
              this.appendOption(name, code);
            }
            if (this._previous_values.contains(code)) {
              reselectable.push(code);
            }
          }
          this._select.val((ref = reselectable[0]) != null ? ref : "");
          return this.showSelect();
        } else {
          return this.showAdd();
        }
      };

      InstitutionOrEmployer.prototype.appendOption = function(name, code) {
        return this._select.append($("<option />").val(code).text(name));
      };

      InstitutionOrEmployer.prototype.showAdd = function(e) {
        if (e != null) {
          e.preventDefault();
        }
        if (this._country_chooser.find(":selected").text() !== 'Hong Kong') {
          this._other.find('input').val("");
          this._choose.find('select').val("");
          this._add.enable().show();
          this._adder.hide();
          this._other.hide();
          this._otherer.show();
          this._choose.hide();
          this._chooser.show();
          return this._otherer.before(this._or);
        }
      };

      InstitutionOrEmployer.prototype.showSelect = function(e) {
        if (e != null) {
          e.preventDefault();
        }
        this._other.find('input').val("");
        this._add.find('input').val("");
        this._add.hide();
        if (this._country_chooser.find(":selected").text() !== 'Hong Kong') {
          this._adder.show();
        }
        this._other.hide();
        this._otherer.show();
        this._choose.enable().show();
        this._chooser.hide();
        return this._otherer.before(this._or);
      };

      InstitutionOrEmployer.prototype.showOther = function(e) {
        if (e != null) {
          e.preventDefault();
        }
        this._add.find('input').val("");
        this._choose.find('select').val("");
        this._add.hide();
        if (this._country_chooser.find(":selected").text() !== 'Hong Kong') {
          this._adder.show();
        }
        this._other.enable().show();
        this._otherer.hide();
        this._choose.hide();
        this._chooser.show();
        return this._adder.before(this._or);
      };

      return InstitutionOrEmployer;

    })();
    return $.fn.country_dependent = function() {
      return this.each(function() {
        var $el, country_select, toggle;
        $el = $(this);
        country_select = $el.parents('form').find('select[data-role="countrypicker"]');
        if (country_select.length) {
          toggle = function(e) {
            if (country_select.val() === $el.attr('data-country')) {
              return $el.show();
            } else {
              return $el.hide();
            }
          };
          country_select.bind('change', toggle);
          return toggle();
        }
      });
    };
  });

}).call(this);