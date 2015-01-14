define([

  'App'

], function (DSW) {

  'use strict';

  DSW.module('Modules.ProjectNavigation', function (module, app) {

    module.startWithParent = false;

    module.on('start', function (data) {
      require(['views/composite/ProjectNavigation'], function (ProjectNavigationView) {
        console.log(data);
        var projectNavView = new ProjectNavigationView({model: data});
        app.trigger('workspace:nav:show', projectNavView);
      });
    });

  })

  return DSW.Modules.ProjectNavigation;

});
