// https://medium.com/@podmedicsed/remote-select-input-with-rails-searckick-and-selectize-d6621f0ee008

$(document).on('turbolinks:load', function(){

  $('#source_parent_id').selectize({
    valueField: 'id',
    labelField: 'identifier_stable',
    searchField: 'identifier_stable',
    create: false,
    load: function(query, callback) {
      console.log(query);
      if (!query.length) return callback();
      $.ajax({
        url: "/sources.json",
        data: { search: query},
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
        return '<div>' + escape(item.identifier_stable) + '</div>'
      }
    }
  });
});