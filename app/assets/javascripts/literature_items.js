$(document).on('turbolinks:load', function(){
  selectize_biblio_search('#literature_item_biblio_data');
  selectize_literature_item('.literature_items');
});

$(document).on('cocoon:after-insert', function(){
  selectize_literature_item('.literature_items');
});

function selectize_biblio_search(object) {
  $(String(object)).selectize({
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
};

function selectize_literature_item(object) {
  $(String(object)).selectize();
};