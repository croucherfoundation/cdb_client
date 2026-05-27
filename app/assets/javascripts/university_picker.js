// University Picker - Selectize-based typeahead for university search
// Initializes on elements with data-role="university-picker"
//
(function($) {
  'use strict';

  function initUniversityPicker($el) {
    var searchUrl = $el.data('search-url');
    var minChars = 2;
    var maxItems = 10;

    $el.selectize({
      valueField: 'id',
      labelField: 'canonical_name',
      searchField: ['canonical_name', 'country'],
      maxItems: 1,
      create: true,
      createOnBlur: true,
      createFilter: function(input) {
        return input.length >= minChars;
      },
      create: function(input) {
        return { id: '', canonical_name: input, country: '', custom: true };
      },
      render: {
        option: function(item, escape) {
          return '<div class="university-option">' +
            '<span class="university-name">' + escape(item.canonical_name) + '</span>' +
            (item.country ? '<span class="university-country">' + escape(item.country) + '</span>' : '') +
          '</div>';
        },
        item: function(item, escape) {
          return '<div>' + escape(item.canonical_name) + '</div>';
        }
      },
      load: function(query, callback) {
        if (query.length < minChars) return callback();
        $.ajax({
          url: searchUrl,
          data: { q: query },
          dataType: 'json',
          error: function() { callback(); },
          success: function(res) { callback(res.slice(0, maxItems)); }
        });
      },
      onChange: function(value) {
        var $container = $el.closest('.university-picker-field');
        var $confirmedField = $container.find('[data-role="user-confirmed-name"]');
        var item = this.options[value];

        if (item && !item.custom) {
          $confirmedField.val(item.canonical_name);
        } else if (item && item.custom) {
          $confirmedField.val(item.canonical_name);
        } else {
          $confirmedField.val('');
        }
      }
    });
  }

  $(document).on('turbo:load ready', function() {
    $('[data-role="university-picker"]').each(function() {
      if (!this.selectize) {
        initUniversityPicker($(this));
      }
    });
  });

})(jQuery);
