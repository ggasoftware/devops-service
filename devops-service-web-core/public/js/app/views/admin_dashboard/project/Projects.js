define([

  'jquery',

  'hbs!templates/admin_dashboard/project/row',
  'hbs!templates/admin_dashboard/project/table',

  'backbone',
  'marionette',

  'App'

], function($, itemTemplate, tableTemplate, Backbone, Marionette, App) {

  'use strict';

  var ProjectView = Backbone.Marionette.ItemView.extend({
    tagName : 'tr',
    template : itemTemplate,

    behaviors : {
      CardShowable : {
        resourceName : 'projects'
      }
    }
  });

  return Backbone.Marionette.CompositeView.extend({

    template : tableTemplate,
    childView : ProjectView,
    childViewContainer : 'tbody',

    behaviors : {
      Refetchable : {}
    },

    events : {
      'click .openCreateDialog' : 'openCreateDialog'
    },

    openCreateDialog : function() {
      App.vent.trigger('createProject');
    }

  });
});