define([

  'backbone',

  'models/Image',

  'App'

], function (Backbone, Image, App) {

  'use strict';

  App.module('Collections.Images', function (Images) {

    Images.c = Backbone.Collection.extend({

      model: Image,

      initialize: function (models, options) {
        this.models = models;
        this.url = function () {
          return App.request('url:get', '/images/' + options.provider);
        }
      }

    });

    Images.newEC2 = function () {
      return new Images.c([], {
        provider: 'ec2'
      });
    };

  });

  return App.Collections.Images;

});
