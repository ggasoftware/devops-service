define([

  'App'

], function(DSW) {

  'use strict';

  DSW.module('Modules.ManageEnvironments', {

    moduleClass: DSW.moduleClasses.Common,

    define: function(module, app) {

      module.startWithParent = false;
      module.opts = {};
      module.showDialog = function(projectName) {
        module.opts.projectName = projectName;

        var aLevels = app.request('get:accessLevels');

        if (!aLevels.level2()) {
          app.trigger('alert:show', {
            type: 'danger',
            message: 'Sorry, you\'re not authorized for this operation.'
          });
          app.trigger('workspace:nav:close');
          require(['modules/ProjectsList'], function(ProjectsList) {
            ProjectsList.start();
            ProjectsList.showProjectsList();
          });
          return false;
        }

        app.userRouter.navigate('#projects/' + projectName + '/environments');

        app.trigger('bc:route', new Backbone.Collection([

          {
            title: 'projects',
            link: 'projects'
          },

          {
            title: projectName,
            link: 'projects/' + projectName
          },

          {
            title: 'environments',
            link: 'projects/' + projectName + '/environments'
          }
        ]));

        require(['views/item/LoadingView'], function(LoadingView) {
          var loadingView = new LoadingView({
            title: "Loading Manage Environments...",
            message: "Please wait, loading environments data..."
          });
          app.trigger('workspace:show', loadingView)
        });

        module.fetchDependencies();

      };

      module.getCollectionsToFetch = function(collectionsToFetch, data, colls) {

        var promise = app.request('fetch', collectionsToFetch);

        promise.done(function() {
          module.log('fetching dependencies... Done.');
          data.deps = colls;
          require(['views/modals/ManageEnvironments'], function(ManageEnvironmentsModal) {
            var view = new ManageEnvironmentsModal(data);
            app.trigger('workspace:show', view);
          })
        });

      };

    }
  });

  return DSW.Modules.ManageEnvironments;

});