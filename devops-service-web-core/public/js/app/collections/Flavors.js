define([

  'jquery',
  'backbone',

  'models/Flavor',

  'App'

], function ($, Backbone, Flavor, App) {

  'use strict';

  App.module('Collections.Flavors', function (Flavors) {

    Flavors.c = Backbone.Collection.extend({
      model: Flavor,
      url: App.request('url:get', '/collections/flavors'),

      initialize: function (models, options) {
        App.dlog('init Flavors collection', this);

        if (options && options.provider) {
          this.url = function () {
            return App.request('url:get', '/collections/flavors/' + options.provider);
          }
        }

      }
    });

    Flavors.newEC2 = function () {
      return new Flavors.c([], {
        provider: 'ec2'
      });
    };

  });

  return App.Collections.Flavors;

});
