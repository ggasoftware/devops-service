define([

  'App',
  'backbone'

], function(App, Backbone) {

  'use strict';

  return Backbone.Model.extend({
    urlRoot : App.request('url:get', '/models/group'),

    parse : function(res) {
      return {
        desc : res.desc,
        id : res.id,
        rules : res.rules,
        displayName : res.id,
        keyName : res.id
      };
    }
  });

});
