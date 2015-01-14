define([

  'App'

], function (DSW) {

  'use strict';

  DSW.module('Modules.BootstrapServer', function (module, app) {

    module.startWithParent = false;

    module.showModal = function (data) {
      require(['views/modals/BootstrapServer'], function (BootstrapServer) {
        new BootstrapServer(data);
      })
    };

  });

  return DSW.Modules.BootstrapServer;

});
