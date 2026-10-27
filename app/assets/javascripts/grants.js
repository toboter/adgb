// https://medium.com/@podmedicsed/remote-select-input-with-rails-searckick-and-selectize-d6621f0ee008

function initShareToSelectize($root) {
  var $shareTo = ($root || $(document)).find("#share_to");
  if (!$shareTo.length) return;

  AdgbSelectize.initWhenVisible($shareTo, {
    valueField: "id",
    labelField: "name",
    searchField: "name",
    create: false,
    placeholder: "Share with…",
    load: function (query, callback) {
      if (!query.length) return callback();
      $.ajax({
        url: $shareTo.data("url"),
        data: { search: query },
        dataType: "json",
        type: "GET",
        error: function () {
          callback();
        },
        success: function (res) {
          callback(res.slice(0, 10));
        }
      });
    },
    render: {
      option: function (item, escape) {
        return (
          '<div class="option-label"><span class="option-title">' +
          escape(item.name || "") +
          "</span></div>"
        );
      }
    }
  });
}

// Bootstrapped via AdgbSelectize.boot (turbolinks / shown.bs.modal / cocoon).
// #share_to lives in #access-settings — init only once the modal is visible.
