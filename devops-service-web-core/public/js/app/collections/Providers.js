define([

  'backbone',

  'models/Provider',

  'App'

], function (Backbone, Provider, App) {

  'use strict';

  return Backbone.Collection.extend({
    model: Provider,
    url: App.request('url:get', '/collections/providers'),

    initialize: function () {
      App.dlog('init Providers collection', this);
    }
  });

});
