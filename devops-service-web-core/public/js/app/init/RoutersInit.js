define([

  'App',

  // routers
  'routers/UserRouter',
  'routers/AdminRouters',
  'routers/SettingsRouter',

  // controllers
  'controllers/UserController',
  'controllers/SettingsController',

  // admin controllers
  'controllers/admin/OverviewController',
  'controllers/admin/ProjectsController',
  'controllers/admin/ImagesController',
  'controllers/admin/ServersController',
  'controllers/admin/FlavorsController',
  'controllers/admin/GroupsController',
  'controllers/admin/UsersController',
  'controllers/admin/NetworksController',
  'controllers/admin/KeysController',
  'controllers/admin/ScriptsController'

], function (DSW,
             // routers
             UserRouter, AdminRouters, SettingsRouter,
             // controllers
             UserController, SettingsController,
             // admin controllers
             AdminOverviewController, AdminProjectsController, AdminImagesController, AdminServersController, AdminFlavorsController, AdminGroupsController, AdminUsersController, AdminNetworksController, AdminKeysController, AdminScriptsController) {

  'use strict';

  DSW.module('Routers', function (module, app) {
    var adminControllers = {
      overview: AdminOverviewController,
      images: AdminImagesController,
      projects: AdminProjectsController,
      servers: AdminServersController,
      flavors: AdminFlavorsController,
      groups: AdminGroupsController,
      users: AdminUsersController,
      networks: AdminNetworksController,
      keys: AdminKeysController,
      scripts: AdminScriptsController
    };

    var createRoutersAndControllers = function () {
      app.Routers = {};
      app.Controllers = {};

      app.Controllers.user = new UserController();
      app.Routers.user = new UserRouter({
        controller: app.Controllers.user
      });

      app.Controllers.settings = new SettingsController();
      app.Routers.settings = new SettingsRouter({
        controller: app.Controllers.settings
      });

      // create admin routers and controllers
      app.Routers.Admin = {};
      app.Controllers.Admin = {};

      _.each(adminControllers, function (Controller, resourceName) {
        app.Controllers.Admin[resourceName] = new Controller();
        app.Routers.Admin[resourceName] = new AdminRouters[resourceName]({
          controller: app.Controllers.Admin[resourceName]
        });
      });
    };

    module.init = function () {
      createRoutersAndControllers();
    }

  });

  return DSW.Routers;

});
