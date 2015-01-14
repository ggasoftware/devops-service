define([

  'jquery',
  'backbone',
  'marionette',

  'hbs!templates/admin_dashboard/key/row',
  'hbs!templates/admin_dashboard/key/table',
  'hbs!templates/admin_dashboard/key/create',


  'App',
  'views/admin_dashboard/key/Card',
  'util/quickJobHandler'

], function($, Backbone, Marionette, itemTemplate, tableTemplate, createTemplate, App, KeyCardView, quickJobHandler) {

  'use strict';

  var KeyView = Backbone.Marionette.ItemView.extend({
    tagName : 'tr',
    template : itemTemplate,

    behaviors : {
      CardShowable : {
        resourceName : 'keys'
      }
    }
  });

  var KeyCreateView = Backbone.Marionette.CompositeView.extend({

    tagName : 'div',
    template : createTemplate,

    events : {
      'click .createKey' : 'createKey',
      'change .file' : 'takeFile'
    },

    takeFile : function(e) {
      var file = e.currentTarget.files[0];
      this.readFile(file);
    },

    readFile : function(file) {
      var reader = new FileReader();
      var that = this;
      reader.onload = function() {
        var contents = event.target.result;
        that.keyFileContent = contents;
        that.keyFileName = file.name;
      };
      reader.readAsText(file);
    },

    createKey : function() {
      var keyData = $('#add-key-form').serializeArray();
      keyData.push({
        'name' : 'content',
        'value' : this.keyFileContent
      });
      keyData.push({
        'name' : 'file_name',
        'value' : this.keyFileName
      });
      quickJobHandler.createKey(keyData);
    }

  });

  return Backbone.Marionette.CompositeView.extend({

    template : tableTemplate,
    childView : KeyView,
    childViewContainer : 'tbody',

    behaviors : {
      Refetchable : {}
    },

    events : {
      'click .openCreateDialog' : 'openCreateDialog'
    },

    openCreateDialog : function() {
      App.workspaceRegion.currentView.table.show(new KeyCreateView());
    }

  });

});
