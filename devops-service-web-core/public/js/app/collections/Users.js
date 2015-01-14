define([

  'backbone',
  'models/User',

  'App'

], function (Backbone, User, App) {

  'use strict';

  return Backbone.Collection.extend({

    model: User,

    url: App.request('url:get', '/collections/users'),

    initialize: function () {
      App.dlog('init Users collection', this);
    }

  });

});
