define([

  'jquery',
  'backbone',

  'models/Project',

  'App'

], function ($, Backbone, Project, App) {

  'use strict';

  return Backbone.Collection.extend({

    model: Project,
    url: App.request('url:get', '/collections/projects'),

    initialize: function () {
      App.dlog('init Projects collection', this);
      this.url = function () {
        var pp = App.request('pathPrefix');
        if (pp) {
          return pp + '/collections/projects';
        }
        return App.request('url:get', '/collections/projects');
      }
    }

  });

});
