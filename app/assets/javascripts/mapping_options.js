$(document).on('turbolinks:load', function(){
  $('select.autosubmit').on('change', function(e) {
    e.preventDefault();
    Rails.fire(this.form, "submit")
  });

  $('.select-klass').selectize({
    create: false,
    placeholder: 'Select a model',
  });

  $('.select-attribute').selectize({
    create: false,
    placeholder: 'Select an attribute',
  });
  
});