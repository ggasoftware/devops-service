define([

  'App',

  'controllers/admin/Base',

  'views/admin_dashboard/server/Servers',
  'views/admin_dashboard/server/Card'

], function (App, BaseAdminController, ServersView, ServerView) {
  
  'use strict';

    return BaseAdminController.extend({

    name : 'servers',
    indexView : ServersView,
    showView : ServerView,

    mainCollection : function() {
      return App.servers_common;
    },

    requredCollections : function() {
      return [ App.servers_common, App.servers_openstack, App.servers_chef, App.servers_ec2 ];
    }

  });

});