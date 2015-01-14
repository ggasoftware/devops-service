define([

  'backbone'

], function(Backbone) {
  
  'use strict';

  return Backbone.Model.extend({

    urlRoot : '/models/script',

    parse : function(res) {
      return {
        id : res
      };
    }

  });

});