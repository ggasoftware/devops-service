define([

  'backbone',

  'models/Script',

  'App'

], function (Backbone, Script, App) {

  'use strict';

  App.module('Collections.Scripts', function (Scripts) {

    Scripts.c = Backbone.Collection.extend({

      model: Script,

      url: App.request('url:get', '/collections/scripts'),

      initialize: function () {
        App.dlog('init Scripts collection', this);
      }

    });

    App.addInitializer(function () {
      App.Collections.Scripts._default = new Scripts.c();
    });

  });

});
