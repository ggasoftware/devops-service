define([

  'backbone'

], function(Backbone) {

  'use strict';

  return Backbone.Model.extend({

    urlRoot : App.request('url:ger', '/api/reports'),

    parse : function(res) {
      return {
        file : res.file,
        created : res.created,
        status : res.status
      };
    }
  });
});
