define([

  'jquery',

  'hbs!templates/admin_dashboard/script/row',
  'hbs!templates/admin_dashboard/script/table',
  'hbs!templates/admin_dashboard/script/create',

  'backbone',
  'marionette',

  'App'

], function($, itemTemplate, tableTemplate, createTemplate, Backbone, Marionette, App) {
  
  'use strict';

  var ScriptView = Backbone.Marionette.ItemView.extend({

    tagName : 'tr',
    template : itemTemplate,

    behaviors : {
      CardShowable : {
        resourceName : 'scripts'
      }
    }

  });

  return Backbone.Marionette.CompositeView.extend({

    template : tableTemplate,
    childView : ScriptView,
    childViewContainer : 'tbody',

    behaviors : {
      Refetchable : {}
    },

    events : {
      'click .openCreateDialog' : 'openCreateDialog'
    },

    openCreateDialog : function() {
      App.vent.trigger('script:add');
    }

  });

});