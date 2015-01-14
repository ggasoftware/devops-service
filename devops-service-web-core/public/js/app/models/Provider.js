define ([

  'jquery',
  'backbone'

], function($, Backbone) {

  'use strict';

  var Provider = Backbone.Model.extend({

    parse : function(res) {
      return {
        id : res,
        displayName : res,
        keyName : res
      };
    }
  });

  return Provider;
});