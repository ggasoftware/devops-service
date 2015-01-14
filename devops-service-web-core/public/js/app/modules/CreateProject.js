define([

  'App'

], function (DSW) {

  'use strict';

  DSW.module('Modules.CreateProject', function (module, app) {

    module.startWithParent = false;

    module.showModal = function (opts) {

      opts = opts || {};

      var type = '';

      if (opts.request) {
        type = 'request';
      } else {
        type = 'new'
      }

      app.userRouter.navigate('#projects/' + type);

      app.trigger('bc:route', new Backbone.Collection([
        {
          title: 'projects',
          link: 'projects'
        },
        {
          title: type,
          link: 'projects/' + type
        }

      ]));

      require(['views/item/LoadingView'], function (LoadingView) {
        var loadingView = new LoadingView({
          title: "Loading Project Create...",
          message: "Please wait, loading collections data..."
        });
        app.trigger('workspace:show', loadingView)
      });

      var colls = {};
      var collectionsToFetch = [];

      require([
        'collections/Providers',
        'collections/Groups',
        'collections/Networks',
        'collections/Flavors',
        'collections/Users',
        'collections/Images',
        'collections/ChefServerEnvironments'
      ], function (Providers, Groups, Networks, Flavors, Users, Images, ChefEnvs) {

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
          colls.chefEnvs
        ];

        var promise = app.request('fetch', collectionsToFetch);

        promise.done(function () {
          var data = {};
          data.deps = colls;
          data.type = type;
          require(['views/modals/CreateProject'], function (CreateProjectView) {
            var view = new CreateProjectView(data);
            app.trigger('workspace:show', view);
          })
        })
      });

    };

  });

  return DSW.Modules.CreateProject;

});
