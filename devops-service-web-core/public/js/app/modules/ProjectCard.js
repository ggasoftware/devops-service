define([

  'App'

], function (DSW) {

  'use strict';

  DSW.module('Modules.ProjectCard', function (module, app) {

    module.startWithParent = false;

    module.showProjectCard = function (projectName) {

      app.userRouter.navigate('projects/' + projectName);
      app.trigger('bc:route', new Backbone.Collection([
        {
          title: 'projects',
          link: 'projects'
        },
        {
          title: projectName,
          link: 'projects/' + projectName
        }
      ]));

      require(['views/item/LoadingView', 'views/layouts/ProjectCardLayout', 'models/Project'],
        function (LoadingView, ProjectCardLayout, ProjectModel) {
          var project = new ProjectModel({id: projectName});
          var loadingView = new LoadingView({
            title: "Loading " + projectName + " project...",
            message: "Please wait, loading data for " + projectName + " project."
          });
          app.trigger('workspace:show', loadingView);

          var fetchingProject = app.request('fetch', project);
          $.when(fetchingProject).done(function (r) {
            require(['views/composite/ProjectNavigation'], function (ProjectNavigationView) {
              var projectNavigationView = new ProjectNavigationView({
                model: project
              });
              app.trigger('workspace:nav:show', projectNavigationView);
              app.navbarRegionNav
            });
            var projectCardLayout = new ProjectCardLayout({
              model: project
            });
            app.trigger('workspace:show', projectCardLayout);
          })

        });
    };

  });

  return DSW.Modules.ProjectCard;

});
