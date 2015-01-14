define([

  'App'

], function (DSW) {

  'use strict';

  DSW.module('Modules.StartDeployEnvironment', function (module, app) {

    module.startWithParent = false;

    module.showModal = function (data) {
      require(['views/modals/DeployEnvironment'], function (DeployEnvironmentModal) {
        new DeployEnvironmentModal(data);
      })
    };

  });

  return DSW.Modules.StartDeployEnvironment;

});
