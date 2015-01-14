define([

  'App',

  'controllers/admin/Base',

  'views/admin_dashboard/user/Users'

], function (App, BaseAdminController, IndexView) {
  
  'use strict';

  return BaseAdminController.extend({

    name : 'users',
    indexView : IndexView,

    mainCollection : function() {
      return App.users;
    },

    requredCollections : function() {
      return [ App.users ];
    }

  });

});