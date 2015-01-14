define([

    'App',

    'controllers/admin/Base',

    'views/admin_dashboard/key/Keys',
    'views/admin_dashboard/key/Card'

], function(App, BaseAdminController, IndexView, ShowView) {

  'use strict';

  return BaseAdminController.extend({

    name : 'keys',

    mainCollection : function() {
      return App.keys;
    },

    requredCollections : function() {
      return [ App.keys ];
    },

    indexView : IndexView,
    showView : ShowView

  });

});
