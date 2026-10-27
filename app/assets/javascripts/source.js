// https://medium.com/@podmedicsed/remote-select-input-with-rails-searckick-and-selectize-d6621f0ee008
// Bootstrapped via AdgbSelectize.boot (turbolinks / cocoon / shown.bs.modal).

function selectize_source(object) {
  AdgbSelectize.init($(object), {
    valueField: "id",
    labelField: "call_number",
    searchField: ["call_number", "sheet", "temp_call_number"],
    create: false,
    placeholder: "Search sources…",
    loadThrottle: 300,
    // Remote results are already filtered by Searchkick — don't drop them client-side.
    score: function () {
      return function () {
        return 1;
      };
    },
    load: function (query, callback) {
      if (!query.length) return callback();
      $.ajax({
        url: "/sources.json?view=simple",
        data: { search: query },
        dataType: "json",
        type: "GET",
        error: function () {
          callback();
        },
        success: function (res) {
          callback(Array.isArray(res) ? res.slice(0, 10) : []);
        }
      });
    },
    render: {
      option: function (item, escape) {
        var title = escape(item.call_number || "");
        if (item.sheet) title += " :: " + escape(item.sheet);
        var meta = item.type
          ? '<span class="option-meta text-muted text-small">' + escape(item.type) + "</span>"
          : "";
        return (
          '<div class="option-label"><span class="option-title">' +
          title +
          "</span>" +
          meta +
          "</div>"
        );
      },
      item: function (item, escape) {
        var label = item.call_number || item.name || item.text || item.id;
        var sheet = item.sheet ? " :: " + item.sheet : "";
        return "<div>" + escape(String(label)) + escape(String(sheet)) + "</div>";
      }
    }
  });
}
