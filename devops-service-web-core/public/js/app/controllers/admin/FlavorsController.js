define([

    'App',

    'controllers/admin/Base',

    'views/admin_dashboard/flavor/Flavors'

], function(App, BaseAdminController, IndexView) {

  'use strict';

  return BaseAdminController.extend({

    name : 'flavors',

    mainCollection : function() {
      return App.flavors_openstack;
    },

    requredCollections : function() {
      return [ App.flavors_openstack, App.flavors_ec2 ];
    },

    indexView : IndexView

  });

});
