// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require bootstrap
//= require cocoon
//= require toastr
//= require bootstrap-markdown-bundle
//= require underscore
//= require gmaps/google
//= require Chart.bundle
//= require chartkick
//= require magnific-popup
//= require selectize
//= require turbolinks
//= require_tree .

/*global toastr*/
toastr.options = {
    "closeButton": true,
    "debug": false,
    "positionClass": "toast-top-left",
}

$(document).ready(function() {

    //select all checkboxes
    $("#select_all").change(function(){  //"select all" change 
        $(".checkbox").prop('checked', $(this).prop("checked")); //change all ".checkbox" checked status
    });

    //".checkbox" change 
    $('.checkbox').change(function(){ 
        //uncheck "select all", if one of the listed checkbox item is unchecked
        if(false == $(this).prop("checked")){ //if this item is unchecked
            $("#select_all").prop('checked', false); //change "select all" checked status to false
        }
        //check "select all" if all checkbox items are checked
        if ($('.checkbox:checked').length == $('.checkbox').length ){
            $("#select_all").prop('checked', true);
        }
    });

    $(function () {
        $('[data-toggle="tooltip"]').tooltip()
    });

    $('.flex-images').flexImages({rowHeight: 200});
    
    $('.lightbox-link').magnificPopup({
        type: 'image',
        mainClass: 'mfp-with-zoom',
        
        zoom: {
          enabled: true, // By default it's false, so don't forget to enable it
    
          duration: 300, // duration of the effect, in milliseconds
          easing: 'ease-in-out', // CSS transition easing function
    
          // The "opener" function should return the element from which popup will be zoomed in
          // and to which popup will be scaled down
          // By defailt it looks for an image tag:
          opener: function(openerElement) {
            // openerElement is the element on which popup was initialized, in this case its <a> tag
            // you don't need to add "opener" option if this code matches your needs, it's defailt one.
            return openerElement.is('img') ? openerElement : openerElement.find('img');
          }
        }
    });
    
});