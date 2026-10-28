$(document).on('turbolinks:load', function(){
  if ( $( "#dashboard-container" ).length ) {
  var UppyCtor = Uppy.Uppy || Uppy.Core;
  var uppy = new UppyCtor({
    autoProceed: false,
    debug: true,
    restrictions: {
      maxFileSize: null,
      maxNumberOfFiles: null,
      minNumberOfFiles: null,
      allowedFileTypes: $('#dashboard-container').data('file-types')
    }
  })
  uppy.use(Uppy.Dashboard, {
    inline: true,
    trigger: '#openDashboardModal',
    height: 300,
    target: '#dashboard-container'
  })
  uppy.use(Uppy.XHRUpload, {
    endpoint: $('#dashboard-container').data('url'),
    formData: true,
    fieldName: 'upload[file]',
    headers: {
      'authorization': 'Bearer ' + $('#dashboard-container').data('token')
    },
    getResponseData: function (xhr) {
      var response = JSON.parse(xhr.responseText);
      var file = response.file || response;
      return Object.assign({}, file, { url: file.file_url || file.url });
    }
  })
  uppy.use(Uppy.Form, {
    target: 'form.with_referenceables',
    getMetaFromForm: false,
    addResultToForm: true,
    resultName: 'attachments',
    submitOnSuccess: false
  })
  }
});
