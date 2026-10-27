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
//= require Chart.bundle
//= require chartkick
//= require magnific-popup/dist/jquery.magnific-popup.min
//= require leaflet/dist/leaflet
//= require leaflet.markercluster/dist/leaflet.markercluster
//= require @selectize/selectize/dist/js/selectize.min
//= require selectize_helpers
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
        Rails.fire($('#search-artefacts')[0].form, 'submit');
    });
    $('.filter-link').tooltip({
        title: 'Click to filter for this attribute.',
        delay: 300,
        placement : 'left'
    });

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

    function updateBulkActionCount($modal) {
        var checked = $('.checkbox:checked').length;
        var itemName = $modal.data('item-name') || 'records';
        var total = parseInt($('#page-result-info').attr('data-total'), 10) || 0;
        var $count = $modal.find('.bulk-action-count');
        var isAccess = $modal.is('#access-settings');

        $count.removeClass('alert-info alert-warning').addClass(checked > 0 ? 'alert-info' : 'alert-warning');

        if (checked > 0) {
            if (isAccess) {
                $count.html(
                    'Scope: <strong>' + checked + ' checked ' + itemName + '</strong>. ' +
                    'Sharing or revoking access below applies only to those records.'
                );
            } else {
                $count.html('This will change <strong>' + checked + ' checked ' + itemName + '</strong>.');
            }
        } else {
            if (isAccess) {
                $count.html(
                    '<strong>No ' + itemName + ' are checked.</strong> ' +
                    'Sharing or revoking access below will change accessibility for ' +
                    '<strong>all ' + total + ' ' + itemName + '</strong> in the current search results.'
                );
            } else {
                $count.html(
                    '<strong>No ' + itemName + ' are checked.</strong> ' +
                    'This will change <strong>all ' + total + ' ' + itemName + '</strong> in the current search results.'
                );
            }
        }

        $modal.find('form.bulk-record-ids-form [type="submit"]').each(function () {
            var $btn = $(this);
            var base = $btn.data('base-label') || $btn.val();
            $btn.data('base-label', base);
            if (checked > 0) {
                $btn.val(base + ' (' + checked + ' checked)');
            } else {
                $btn.val(base + ' (all ' + total + ')');
            }
        });
    }

    $(document).on('show.bs.modal', '.bulk-action-modal', function () {
        updateBulkActionCount($(this));
    });

    // Bulk modals live outside the list form — copy checked row ids in on submit.
    $(document).on('submit', 'form.bulk-record-ids-form, #access-settings form', function () {
        var $form = $(this);
        $form.find('input[name="record_ids[]"]').remove();
        $('.checkbox:checked').each(function () {
            $('<input>').attr({ type: 'hidden', name: 'record_ids[]', value: this.value }).appendTo($form);
        });
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
