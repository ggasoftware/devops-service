define([

  'backbone',

  'models/Group',

  'App'

], function (Backbone, Group, App) {

  'use strict';

  App.module('Collections.Groups', function (Groups) {

    Groups.c = Backbone.Collection.extend({

      model: Group,
      url: App.request('url:get', '/collections/groups/openstack'),

      initialize: function (models, options) {
        App.dlog("init Groups collection", this);
        this.models = models;
        this.url = function () {
          return App.request('url:get', '/collections/groups/' + options.provider);
        }
      },

      parse: function (response) {
        var res = [];
        _.each(response, function (object, name) {
          res.push({
            id: name,
            displayName: name,
            desc: object.description,
            rules: object.rules
          });
        });
        return res;
      }

    });

    Groups.newEC2 = function () {
      return new Groups.c([], {
        provider: 'ec2'
      });
    };

  });

  return App.Collections.Groups;

});
