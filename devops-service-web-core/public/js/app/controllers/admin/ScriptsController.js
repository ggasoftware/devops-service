define([

  'App',

  'controllers/admin/Base',

  'views/admin_dashboard/script/Scripts',
  'views/admin_dashboard/script/Card'

], function (App, BaseAdminController, IndexView, ShowView) {
  
  'use strict';

  return BaseAdminController.extend({

    name: 'scripts',

    mainCollection: function() {
      return App.scripts;
    },

    requredCollections: function() {
      return [ App.scripts ];
    },

    indexView: IndexView,
    showView: ShowView

  });

});
