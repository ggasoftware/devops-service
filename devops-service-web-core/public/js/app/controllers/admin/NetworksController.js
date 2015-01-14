define([

    'App',
    'controllers/admin/Base',
    'views/admin_dashboard/network/Networks'

], function(App, BaseAdminController, IndexView) {

  'use strict';

  return BaseAdminController.extend({

    name : 'networks',

    mainCollection : function() {
      return App.networks_openstack;
    },

    requredCollections : function() {
      return [ App.networks_openstack, App.networks_ec2 ];
    },

    indexView : IndexView

  });

});