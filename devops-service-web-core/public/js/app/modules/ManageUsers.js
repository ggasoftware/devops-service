define([

  'App'

], function (DSW) {

  'use strict';

  DSW.module('Modules.ManageUsers', function (module, app) {

    module.startWithParent = false;

    module.showModal = function (data) {
      require(['views/modals/ManageUsers'], function (ManageUsers) {
        new ManageUsers(data);
      })
    };

  });

  return DSW.Modules.ManageUsers;

});
