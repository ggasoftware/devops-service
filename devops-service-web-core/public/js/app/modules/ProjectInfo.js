define([

  'App'

], function (DSW) {

  'use strict';

  DSW.module('Modules.ProjectInfo', function (module, app) {

    module.startWithParent = false;

    module.showModal = function (data) {
      require(['views/modals/ProjectInfo'], function (ProjectInfoModal) {
        new ProjectInfoModal(data);
      })
    };

  });

  return DSW.Modules.ProjectInfo;

});
