define([

  'backbone',
  'marionette',

  'App',
  'views/admin_dashboard/behaviours/Refetchable',
  'views/admin_dashboard/behaviours/CardShowable',
  'views/admin_dashboard/behaviours/HasBackLink'

], function(Backbone, Marionette, App, Refetchable, CardShowable, HasBackLink) {

  'use strict';
  return {

    init: function() {
      App.Behaviors = {};
      Marionette.Behaviors.behaviorsLookup = function() {
        return App.Behaviors;
      };

      App.Behaviors.Refetchable = Refetchable;
      App.Behaviors.CardShowable = CardShowable;
      App.Behaviors.HasBackLink = HasBackLink;
    }

  };
});
