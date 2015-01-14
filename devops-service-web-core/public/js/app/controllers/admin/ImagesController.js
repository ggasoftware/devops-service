define([

    'App',

    'controllers/admin/Base',

    'views/admin_dashboard/image/Images',
    'views/admin_dashboard/image/Card'

], function(App, BaseAdminController, ImagesView, ImageView) {

  'use strict';

  return BaseAdminController.extend({

    name : 'images',

    mainCollection : function() {
      return App.images_all;
    },

    requredCollections : function() {
      return [ App.images_all, App.images_openstack, App.images_ec2 ];
    },

    indexView : ImagesView,
    showView : ImageView

  });

});
