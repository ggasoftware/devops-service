define([

  'jquery',
  'backbone',
  'App',
  'models/DeployEnv',
  'collections/DeployEnvironments',
  'collections/Servers'

], function ($, Backbone, App, DeployEnv, DeployEnvironments, Servers) {

  'use strict';

  return Backbone.Model.extend({

    urlRoot: App.request('url:get', '/models/project'),

    initialize: function () {
      var envs = new DeployEnvironments();
      envs.url = App.request('url:get', '/project/' + this.id);
      envs.project_id = this.id;
      this.set('envs', envs);

      var servers = new App.Collections.Servers.c();
      servers.url = App.request('url:get', '/project_servers/' + this.id);
      this.set('servers', servers);

      this.initEvents();
    },

    getServersForEnv: function (env_id) {
      var f = [];
      _.each(this.get('servers').models, function (s) {
        if (s.get('modal').deploy_env === env_id) {
          f.push(s);
        }
      });
      return f;
    },

    initEvents: function () {
      //this.listenTo(this.collection, 'models:unselect', this.unselect);
      //this.on('select', this.select);
    },

    getChefEnvForServer: function (envIdentifier) {
      var deployEnvs = this.get('deploy_envs');
      var res;
      _.each(deployEnvs, function (d) {
        var identifier = d.identifier;
        if (identifier === envIdentifier) {
          res = d.chef_env;
        }
      });
      return res;
    },

    getUsers: function (deployEnvs) {
      return _.chain(deployEnvs).map(function (m) {
        return m.users;
      }).flatten().uniq().value();
    },

    select: function () {
      this.set({
        selected: true
      });
    },

    unselect: function () {
      this.set({
        selected: false
      });
    },

    checkOwnershipForCurrentUser: function (user, users) {
      if (!user) {
        user = App.request('get:currentUser');
      }
      var index = _.indexOf(users, user);
      if (index > -1) {
        return true;
      }
      return false;
    },

    checkUserPermissionsForEnv: function (data) {
      var deployEnvs = this.get('deploy_envs');
      var deployEnv = _.find(deployEnvs, function (d) {
        if (d.identifier === data.deployEnv) {
          return true;
        }
      });
      if (deployEnv.users.indexOf(data.user) > -1) {
        return true;
      }
      return false;
    },

    parse: function (res) {
      var that = this;
      var users = this.getUsers(res.deploy_envs);
      var currentUser = App.settings.username;
      var owner = this.checkOwnershipForCurrentUser(currentUser, users);

      return {
        id: res.name,
        jenkinsJobName: res.jenkins_job_name,
        deploy_envs: res.deploy_envs,
        users: that.getUsers(res.deploy_envs),
        owner: owner,
        rawResponse: res
        // TODO implement deploy_envs attribute as Backbone collection
        //deploy_envs: new DeployEnvironments(res.deploy_envs)
      };
    }
  });

});
