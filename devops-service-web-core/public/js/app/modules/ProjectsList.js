define([

  'App'

], function (DSW) {

  'use strict';

  DSW.module('Modules.ProjectsList', function (module, app) {

    module.startWithParent = false;

    module.showProjectsList = function () {

      app.userRouter.navigate('#projects');

      app.trigger('bc:route', new Backbone.Collection([
        {
          title: 'projects',
          link: 'projects'
        }
      ]));

      require(['views/item/LoadingView', 'collections/Projects', 'views/composite/ProjectsList', 'views/item/TotalProjectsCount'],
        function (LoadingView, ProjectsCollection, ProjectsListView, TotalProjectsCountView) {
          var loadingView = new LoadingView({
            title: "Loading Projects...",
            message: "Please wait, loading projects data"
          });
          app.trigger('workspace:show', loadingView);
          var projectsCollection = new ProjectsCollection();
          var fetchingProjects = app.request('fetch', projectsCollection);

          app.trigger('navbar:projects:setActive');
          $.when(fetchingProjects).done(function () {
            var projectsListView = new ProjectsListView({
              collection: projectsCollection
            });
            var totalProjectsCountView = new TotalProjectsCountView({collection: projectsCollection});
            app.trigger('workspace:show', projectsListView);
            app.sidebarInfoRegion.show(totalProjectsCountView);
          })

        });
    };

    module.on('start', function () {
      console.log('>>> started ProjectsList');
    });


  });

  return DSW.Modules.ProjectsList;

});
