define([

  'App',
  'backbone'

], function(App, Backbone) {

  'use strict';


  return Backbone.Model.extend({

    urlRoot : App.request('url:get', '/models/image'),
    rowTemplate : '#image-row-template',

    parse : function(res) {
      return {
        image_id : res.name,
        provider : res.provider,
        remote_user : res.remote_user,
        id : res.id,
        displayName : res.name,
        keyName : res.id
      };
    }
  });

});
