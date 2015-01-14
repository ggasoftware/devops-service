define([

  'jquery',
  'backbone',
  'marionette',

  'App',
  'views/modals/AddEnvironments',
  'views/modals/CreateProject',
  'views/modals/alert/DeleteProject',
  'views/modals/ProjectInfo',
  'views/modals/DeployProject',
  'views/modals/DeployEnvironment',
  'views/modals/BootstrapServer',
	'views/modals/alert/DeleteServer',
  'views/modals/RunScriptModal',
  'views/modals/UserInfo'

  ],function ($, Backbone, Marionette, App, ManageEnvironmentsModal, CreateProjectModal, DeleteProjectModal, ProjectInfoModal, DeployProjectModal, DeployEnvironmentModal, BootstrapServer, DeleteServerModal, RunScriptModal, UserInfoModal) {

  'use strict';

  return Backbone.Marionette.Object.extend({

    getModule : function(moduleType, moduleName) {
      var module = this.modules[moduleType][moduleName];
      var depsPromise;
      if (module.deps.length > 0) {
        depsPromise = App.request('fetch', module.deps);
        var loadingModal = App.request('alert:loading');
        depsPromise.done(function() {
          loadingModal.trigger('deps:fetched');
        });
      } else {
        depsPromise = $.Deferred().resolve();
      }
      return {
        module : this.modules[moduleType][moduleName],
        promise : depsPromise
      };
    },

    initModules : function() {
      this.modules = this.modulesForInit();
    },

      modulesForInit: function() {

        var providers = App.Collections.Providers._;
        var groupsEC2 = App.Collections.Groups._EC2;
        var networksEC2 = App.Collections.Networks._EC2;
        var flavorsEC2 = App.Collections.Flavors._EC2;
        var imagesEC2 = App.Collections.Images._EC2;
        var imagesBlankEC2 = App.Collections.Images._blankEC2;
        var users = App.Collections.Users._;
        var chefServerEnvironments = App.Collections.ChefServerEnvironments._;

      return {

        modal : {

        //var providers = new App.Collections.Providers.c();

          // Project
          'environments:manage' : {
            clazz : ManageEnvironmentsModal,
            deps : [ providers, imagesEC2, flavorsEC2, groupsEC2, networksEC2, users, chefServerEnvironments ]
          },
          'project:create' : {
            clazz : CreateProjectModal,
            deps : [ providers, groupsEC2, networksEC2, flavorsEC2, users, imagesEC2, imagesBlankEC2 ]
            //deps : [ App.providers, App.groups_ec2, App.networks_ec2, App.flavors_ec2, App.users, App.images_ec2, App.images_ec2_blank, App.chefServerEnvironments ]
          },
          'project:deploy' : {
            clazz : DeployProjectModal,
            deps : []
          },
          'project:environment:deploy' : {
            clazz : DeployEnvironmentModal,
            deps : []
          },
          'project:delete' : {
            clazz : DeleteProjectModal,
            deps : []
          },
          'users:manage' : {
            //clazz : ManageUsersModal,
            //deps : [ App.users ]
          },
          "user:info": {
            clazz: UserInfoModal, deps: [App.users]
          },
          'project:info' : {
            clazz : ProjectInfoModal,
            deps : []
          },
          'project:server:bootstrap' : {
            clazz : BootstrapServer,
            deps : []
          },

          //Server
          'server:delete' : {
            clazz : DeleteServerModal,
            deps : []
          },
          'server:runScript' : {
            clazz : RunScriptModal,
            deps : [ App.scripts ]
          }

        }

      };
    }

  });
});
