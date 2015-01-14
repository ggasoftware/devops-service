define([

  'backbone'

], function (Backbone) {

  'use strict';

  return Backbone.Model.extend({

    parse: function (res) {

      var type = (function () {
          var cType = res.type;
          if (cType === 1) {
            return "deploy"
          }
          if (cType === 2) {
            return "launch"
          }
          if (cType === 3) {
            return "bootstrap"
          }
          if (cType === 4) {
            return "test"
          }
        })();

      return {
        file: res.file,
        createdAt: res.created_at,
        createdBy: res.created_by,
        project: res.project,
        deployEnv: res.deploy_env,
        type: type,

        id: res.id,
        status: res.status
      };
    }
  });
});
