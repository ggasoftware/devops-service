define([

  'App',

  'backbone'
  
], function(App, Backbone) {

  'use strict';

  return {
    redirect_to : function(path) {
      Backbone.history.navigate(path, {
        trigger : true
      });
    }
  };
});