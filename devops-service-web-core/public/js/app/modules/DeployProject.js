define([

  'App'

], function (DSW) {

  'use strict';

  DSW.module('Modules.DeployProject', function (module, app) {

    module.startWithParent = false;

    module.showModal = function (data) {
      require(['views/modals/DeployProject'], function (DeployProjectModal) {
        new DeployProjectModal(data);
      });
    }

  });

  return DSW.Modules.DeployProject;

});
