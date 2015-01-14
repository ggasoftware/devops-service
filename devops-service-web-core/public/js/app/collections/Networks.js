define([

  'backbone',

  'models/Network',

  'App'

], function (Backbone, Network, App) {

  'use strict';

  App.module('Collections.Networks', function (Networks) {

    Networks.c = Backbone.Collection.extend({
      model: Network,
      url: App.request('url:get', '/collections/networks'),

      initialize: function (models, options) {
        App.dlog('init Networks collection', this);
        if (options && options.provider) {
          this.url = function () {
            return App.request('url:get', '/collections/networks/' + options.provider);
          }
        }
      }

    });

    Networks.newEC2 = function () {
      return new Networks.c([], {
        provider: 'ec2'
      });
    };

  });

  return App.Collections.Networks;

});
