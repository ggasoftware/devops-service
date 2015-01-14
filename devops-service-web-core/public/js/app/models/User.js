define([

  'backbone'

], function(Backbone) {

  'use strict';

  return Backbone.Model.extend({

    parse : function(res) {
      return {
        id : res.id,
        displayName : res.id,
        keyName : res.id,
        privileges : {
          provider : res.privileges.provider,
          flavor : res.privileges.flavor,
          group : res.privileges.group,
          image : res.privileges.image,
          key : res.privileges.key,
          project : res.privileges.project,
          server : res.privileges.server,
          user : res.privileges.user,
          filters : res.privileges.filters,
          network : res.privileges.network,
          script : res.privileges.script
        }
      };
    }
  });

});