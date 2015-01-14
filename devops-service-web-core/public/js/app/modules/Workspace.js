define([

  'App'

], function (DSW) {

  'use strict';

  DSW.module('Modules.Workspace', function (module, app) {

    module.startWithParent = false;

    module.on('start', function () {
      console.log('>>> started Workspace');

      require(['views/layouts/WorkspaceLayout'], function (WorkspaceLayout) {
        app.workspaceRegion.show(new WorkspaceLayout());
      });

    });

    module.showProjectCard = function (data) {
      var projectName = data.model.get('id');
      require(['modules/ProjectCard'], function (ProjectCard) {
        ProjectCard.start(projectName);
        ProjectCard.showProjectCard(projectName);
      });
    };

    module.listenTo(app, 'workspace:project:show', module.showProjectCard);

  });

  return DSW.Modules.Workspace;

});
