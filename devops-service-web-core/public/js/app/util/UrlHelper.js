define([

  'backbone',

  'App'


], function(Backbone, App) {

  'use strict';

  return Backbone.Marionette.Object.extend({

    initialize : function() {
      this.initEvents();
    },

    initEvents : function() {
      App.reqres.setHandler('url:get', this.getUrl);
    },

    getUrl : function(string) {
      var str = App.request('pathPrefix') + string;
      return str;
    }
  });

});
