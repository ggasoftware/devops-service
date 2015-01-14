define([

  'jquery',
  'backbone',
  'marionette',

  'hbs!templates/user_dashboard/projects_list/list_item',

  'App'

], function($, Backbone, Marionette, itemTemplate, App) {

  'use strict';

  return Backbone.Marionette.ItemView.extend({

    template : itemTemplate,
    tagName : 'tr',

    className : function() {
      var owner = this.model.get('owner');
      if (owner) {
        return 'owner';
      }
    },

    events : {
      'click' : 'showProject'
    },

    modelEvents : {
      'select' : 'selected'
    },

    showProject : function(e) {
      e.preventDefault();
      App.trigger('workspace:project:show', { model: this.model });
      //this.model.collection.trigger('models:unselect');
      //this.model.trigger('select');
    },

    hideIfBingo : function(filterString, showingMy) {
      var sub1 = this.model.get('id').toLowerCase();
      if(showingMy && !this.model.get('owner')) {
        $(this.el).hide();
        return;
      }
      if (sub1.indexOf(filterString) !== -1) {
        $(this.el).show();
      } else {
        $(this.el).hide();
      }
    },

    selected : function() {
      this.$el.addClass('active');
      var projectId = this.model.get('id');
      App.vent.trigger('layout:workspace:project:show', projectId);
    }

  });

});
