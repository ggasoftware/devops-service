define([

  'backbone',

  'models/Server',
  'models/ServerOpenstack',

  'App'

], function (Backbone, Server, ServerOpenstack, App) {

  'use strict';

  App.module('Collections.Servers', function (Servers) {

    Servers.c = Backbone.Collection.extend({

      model: Server,

      url: App.request('url:get', '/collections/servers'),

      initialize: function (models, options) {
        App.dlog("init Servers collection", this);
        if (options && options.projectId) {
          this.url = function () {
            return App.request('url:get', '/project_servers/' + options.projectId)
          }
        }
      },

      setModelOpenstack: function () {
        this.model = ServerOpenstack;
      },

      parse: function (res) {
        this.rawResponse = res;
        return res;
      }

    });

    App.addInitializer(function () {
//    App.Collections.Servers._ = new Servers.c();
    });

  });

});
