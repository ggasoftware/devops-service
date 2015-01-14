define([

  'jquery',
  'hbs!templates/modals/add_script/modal',
  'backbone',
  'marionette',

  'App',

  'util/quickJobHandler'

], function ($, modalTemplate, Backbone, Marionette, App, quickJobHandler) {

  'use strict';
  return Backbone.Marionette.CompositeView.extend({

    template: modalTemplate,
    tagName: 'div',
    className: 'modal fade in',

    events: {
      'click .createScript' : 'createScript',
      'change .file' : 'takeFile'
    },

    initialize: function () {
      this.render();
      this.$el.modal('toggle');
    },

    takeFile: function(e) {
      var file = e.currentTarget.files[0];
      this.readFile(file);
    },

    readFile: function(file) {
      var reader = new FileReader();
      var that = this;
      reader.onload = function() {
        var contents = event.target.result;
        that.scriptFileContent = contents;
        that.scriptFileName = file.name;
      };
      reader.readAsText(file);
    },

    createScript: function() {
      //TODO show waiting spinner
      var scriptData = $('#add-script-form').serializeArray();
      scriptData.push({'name': 'content', 'value': this.scriptFileContent});
      var that = this;

      var deferred = quickJobHandler.createScript(scriptData);

      deferred.done(function() {
        App.request('refetch', App.scripts);
      });

      deferred.done(function() {
        // TODO: make separate region for modals (http://www.joezimjs.com/javascript/using-marionette-to-display-modal-views/)
        var modal = that.$el;
        modal.on('hidden.bs.modal', function() {
          modal.remove();
        });
        modal.modal('hide');
      });
    }

  });
});
