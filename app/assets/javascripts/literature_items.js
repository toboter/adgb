// Bootstrapped via AdgbSelectize.boot on turbolinks:load / cocoon / modal.

function selectize_biblio_search(object) {
  AdgbSelectize.init($(object), {
    valueField: "value",
    labelField: "shortTitle",
    searchField: ["shortTitle", "cite", "type"],
    placeholder: "Search literature…",
    create: false,
    loadThrottle: 500,
    load: function (query, callback) {
      if (!query.length) return callback();
      $.ajax({
        url: "/bibliography/search",
        data: { q: query },
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
        var meta = item.cite
          ? '<span class="option-meta text-muted text-small">' + escape(item.cite) + "</span>"
          : "";
        return (
          '<div class="option-label"><span class="option-title">' +
          escape(item.shortTitle || "") +
          "</span>" +
          meta +
          "</div>"
        );
      }
    }
  });
}

function selectize_literature_item(object) {
  AdgbSelectize.init($(object), {
    placeholder: "Search literature…",
    searchField: ["text"],
    sortField: "text"
  });
}
