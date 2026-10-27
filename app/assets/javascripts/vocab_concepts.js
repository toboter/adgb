// Bootstrapped via AdgbSelectize.boot on turbolinks:load / cocoon / modal.

function selectize_concepts(object) {
  AdgbSelectize.init($(object), {
    valueField: "value",
    labelField: "name",
    searchField: ["name", "parents", "labels"],
    placeholder: "Search concepts…",
    create: false,
    loadThrottle: 500,
    load: function (query, callback) {
      if (!query.length) return callback();
      $.ajax({
        url: "/concepts/search",
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
        var parents = item.parents
          ? '<span class="option-meta text-muted text-small">' + escape(item.parents) + "</span>"
          : "";
        var note = item.note
          ? '<span class="option-meta text-muted text-small">' + escape(item.note) + "</span>"
          : "";
        return (
          '<div class="option-label"><span class="option-title">' +
          escape(item.name || "") +
          "</span>" +
          parents +
          note +
          "</div>"
        );
      }
    }
  });

  // Trim UUID/metadata suffixes that may appear in item labels.
  $(object)
    .closest(".form-group, .nested-fields, form")
    .find("div.concepts_selectize > div.items > div.item, .selectize-control.concepts_selectize .item")
    .each(function () {
      $(this).text($(this).text().split(";")[0]);
    });
}
