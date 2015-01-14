define([

  'hbs!templates/user_dashboard/project_card/project_card',
  'hbs!templates/user_dashboard/project_card/project_navbar',

  'App'

], function (cardTemplate, projectNavbarTemplate, DSW) {

  'use strict';

  return Backbone.Marionette.CompositeView.extend({

    className: 'dsw-rounded-panel',

    template: projectNavbarTemplate,
    initialize: function (data) {
      this.model = data.model;
    },

    events: {
      'click #project-info': 'projectInfo',
      'click #manage-environments': 'manageEnvironments',
      'click #manage-users': 'manageUsers',
      'click #delete-project': 'deleteProject',
      'click #deploy-project': 'deployProject'
    },

    serializeData: function () {
      return {
        accessLevels: DSW.request('get:accessLevels')
      }
    },

    projectInfo: function () {
      console.log(this.model)
      DSW.vent.trigger('project:info:show', {
        model: this.model
      });
    },

    manageEnvironments: function () {
      var projectName = this.model.get('id');
      DSW.vent.trigger('project:environments:manage', projectName);
    },

    deployProject: function () {
      var projectName = this.model.get('id');
      var user = DSW.request('get:currentUser');
      var denvs = this.model.get('deploy_envs');
      var users = this.model.getUsers(denvs);
      var canDeploy = this.model.checkOwnershipForCurrentUser(user, users);
      if (canDeploy) {
        DSW.vent.trigger('project:deploy:start', {
          model: this.model
        });
      } else {
        DSW.trigger('alert:show', {
          type: 'danger',
          title: "",
          message: "Access denied. You don’t have permissions to deploy this project."
        });
      }
    },

    manageUsers: function () {
      DSW.vent.trigger('project:users:manage', {
        model: this.model
      });
    },

    deleteProject: function () {
      DSW.vent.trigger('project:modal:delete', {
        model: this.model
      });
    }

  });

});
