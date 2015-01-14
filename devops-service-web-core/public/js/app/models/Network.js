define([

  'backbone'

], function(Backbone) {

  'use strict';
  
  return Backbone.Model.extend({

    parse : function(res) {
      return {
        cidr : res.cidr,
        name : res.name,
        id : res.name,
        _id : res.id,
        displayName : "Name: " + res.name + ", CIDR: " + res.cidr,
        keyName : res.name
      };
    }
  });
});
