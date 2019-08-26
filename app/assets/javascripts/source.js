// https://medium.com/@podmedicsed/remote-select-input-with-rails-searckick-and-selectize-d6621f0ee008

$(document).on('turbolinks:load', function(){
  selectize_source('.source_id');

  $('#source_archive_name').selectize({
    create: true
  });

});

$(document).on('cocoon:after-insert', function(){
  selectize_source('.source_id');
});

function selectize_source(object) {
  $(String(object)).selectize({
    valueField: 'id',
    labelField: 'call_number',
    searchField: ['call_number', 'sheet'],
    create: false,
    load: function(query, callback) {
      console.log(query);
      if (!query.length) return callback();
      $.ajax({
        url: "/sources.json?view=simple",
        data: { search: query },
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
        return '<div>' + '<strong>' + escape(item.call_number) + '</strong>' +
                  '<strong>' + ' :: ' + escape(item.sheet) + '</strong>' +
                  '<p class="text-small">' + '<em>' + escape(item.type) + '</em>' + '</p>' +
               '</div>'
      }
    }
  });
}