define([

    'App',

    'controllers/admin/Base',

    'views/admin_dashboard/group/Groups'

], function(App, BaseAdminController, IndexView) {

  'use strict';

  return BaseAdminController.extend({

    name : 'groups',

    mainCollection : function() {
      return App.groups_openstack;
    },

    // TODO fix func name to required
    requredCollections : function() {
      return [ App.groups_openstack, App.groups_ec2 ];
    },

    indexView : IndexView

  });

});
