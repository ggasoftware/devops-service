define([

  'App'

], function (DSW) {

  'use strict';

  DSW.module('Modules.DeleteProject', function (module, app) {

    module.startWithParent = false;

    module.showModal = function (data) {
      require(['views/modals/alert/DeleteProject'], function (DeleteProject) {
        new DeleteProject(data);
      })
    };

  });

  return DSW.Modules.DeleteProject;

});
