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
//= require rails-ujs
//= require jquery/dist/jquery.min
//= require bootstrap
//= require cocoon
//= require toastr/toastr
//= require uppy/dist/uppy.min
//= require underscore/underscore-min
//= require gmaps/google
//= require Chart.bundle
//= require chartkick
//= require magnific-popup/dist/jquery.magnific-popup.min
//= require selectize/dist/js/standalone/selectize.min
//= require bootstrap-tokenfield-jquery3/dist/bootstrap-tokenfield.min
//= require turbolinks
//= require_tree .

/*global toastr*/
toastr.options = {
    "closeButton": true,
    "debug": false,
    "positionClass": "toast-top-left",
}

$(document).on('turbolinks:load', function(){
    // http://sliptree.github.io/bootstrap-tokenfield/
    $('#search-artefacts')
      //.on('tokenfield:removedtoken', function (e) {
      //  console.log(this.form.submit());
      //})
      .tokenfield({
        delimiter: '+'
    });
    $('.filter-link').click(function (e) {
        token = $(this).data('token')
        $('#search-artefacts').tokenfield('createToken', token);
        e.preventDefault(); // Prevent link from following its href
        $('#search-artefacts')[0].form.submit();
    });
    $('.filter-link').tooltip({
        title: 'Click to filter for this attribute.',
        delay: 300,
        placement : 'left'
    });

    $('.user_group_list_item').selectize();

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
        $('[data-toggle="tooltip"]').tooltip();
        $('[data-toggle="popover"]').popover()
    });

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

$(document).on('ready turbolinks:load', function(){

    xmlTEXT = $('#TEI').data('xml-text')
    if (xmlTEXT.length) {
      var CETEIcean = new CETEI()
      CETEIcean.makeHTML5(xmlTEXT, function(data) {
        document.getElementById("TEI").innerHTML = "";
        document.getElementById("TEI").appendChild(data)
      })
    };
});
