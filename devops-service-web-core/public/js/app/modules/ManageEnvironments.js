define([

  'App'

], function (DSW) {

  'use strict';

  DSW.module('Modules.ManageEnvironments', function (module, app) {

    module.startWithParent = false;

    module.showDialog = function (projectName) {

      var aLevels = app.request('get:accessLevels');

      if (!aLevels.level2()) {
        app.trigger('alert:show', {
          type: 'danger',
          message: 'Sorry, you\'re not authorized for this operation.'
        });
        app.trigger('workspace:nav:close');
        require(['modules/ProjectsList'], function (ProjectsList) {
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


      require(['views/item/LoadingView'], function (LoadingView) {
        var loadingView = new LoadingView({
          title: "Loading Manage Environments...",
          message: "Please wait, loading environments data..."
        });
        app.trigger('workspace:show', loadingView)
      });

      var colls = {};
      var collectionsToFetch = [];

      require([
        'models/Project',
        'collections/Providers',
        'collections/Groups',
        'collections/Networks',
        'collections/Flavors',
        'collections/Users',
        'collections/Images',
        'collections/ChefServerEnvironments'
      ], function (Project, Providers, Groups, Networks, Flavors, Users, Images, ChefEnvs) {

        var data = {}
        data.model = new Project({id: projectName});

        colls = {
          providers: new Providers(),
          groups: new Groups.newEC2(),
          networks: new Networks.newEC2(),
          flavors: new Flavors.newEC2(),
          users: new Users(),
          images: new Images.newEC2(),
          chefEnvs: new ChefEnvs.c()
        };

        collectionsToFetch = [
          colls.providers,
          colls.groups,
          colls.networks,
          colls.flavors,
          colls.users,
          colls.images,
          colls.chefEnvs,
          data.model
        ];

        var promise = app.request('fetch', collectionsToFetch);

        promise.done(function () {
          data.deps = colls;
          require(['views/modals/ManageEnvironments'], function (ManageEnvironmentsModal) {
            var view = new ManageEnvironmentsModal(data);
            app.trigger('workspace:show', view);
          })
        })

      })

    };

  });

  return DSW.Modules.ManageEnvironments;

});
