define([

    'App',

    'controllers/admin/Base',

    'views/admin_dashboard/project/Projects',
    'views/admin_dashboard/project/Card'

], function(App, BaseAdminController, ProjectsView, ProjectView) {

  'use strict';

  return BaseAdminController.extend({

    name: 'projects',

    mainCollection : function() {
      return App.projects;
    },

    requredCollections : function() {
      return [ App.projects ];
    },

    indexView : ProjectsView,
    showView : ProjectView

  });

});