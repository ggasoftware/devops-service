define([

  'hbs!templates/admin_dashboard/overview/overview',

  'backbone',

], function(overviewTemplate, Backbone) {

  'use strict';

  return Backbone.Marionette.CompositeView.extend({

    template : overviewTemplate

  });

});