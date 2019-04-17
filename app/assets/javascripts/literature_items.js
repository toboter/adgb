$(document).on('turbolinks:load', function(){

  $('#literature_item_biblio_data').selectize({
    valueField: 'value',
    labelField: 'citation',
    searchField: ['citation', 'cite', 'type'],
    placeholder: 'Search literature...',
    create: false,
    loadThrottle: 500,
    load: function(query, callback) {
      if (!query.length) return callback();
      $.ajax({
        url: "/bibliography/search",
        data: { q: query },
        dataType: "json",
        type: 'GET',
        error: function(res){
          callback();
        },
        success: function(res) {
          callback(res.slice(0,10));
        }
      })
    },
    render: {
      option: function(item, escape) {
        return '<div>' + '<strong>' + escape(item.citation) + '</strong>' +
                  '<p class="text-small">' + '<em>' + escape(item.cite) + '</em>' + '</p>' +
               '</div>'
      }
    }
  });
});