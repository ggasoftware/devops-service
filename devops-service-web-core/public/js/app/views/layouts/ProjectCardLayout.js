define([

  'hbs!templates/user_dashboard/project_card/project_card',
  'hbs!templates/user_dashboard/project_card/project_navbar',

  'App',

  'views/user_dashboard/project/EnvironmentsList',
  'views/user_dashboard/project/server_list/ServerList',
  'collections/DeployEnvironments'

], function (cardTemplate, projectNavbarTemplate, DSW, EnvironmentsListView, ServerListView, DeployEnvironments) {

  'use strict';

  return Backbone.Marionette.LayoutView.extend({

    template: cardTemplate,

    className: 'container-fluid dsw-rounded-panel',

    regions: {
      envs: '#envs',
      projectNav: '#project-nav'
    },

    showEnvs: function () {
      var denvsColl = new DeployEnvironments(this.model.get('deploy_envs'));
      denvsColl.project = this.model;
      this.environmentsView = new EnvironmentsListView({
        collection: denvsColl
      });
      this.envs.show(this.environmentsView);
      var servers = this.model.get('servers');
      servers.fetch();
    },

    refetchProject: function () {
      var self = this;
      var promise = this.model.fetch();
      promise.done(function () {
        self.showEnvs();
      });
    },

    initialize: function () {
      this.listenTo(DSW, 'project:refetch:' + this.model.get('id'), this.refetchProject);
      var denvsColl = new DeployEnvironments(this.model.get('deploy_envs'));
      denvsColl.project = this.model;
      this.environmentsView = new EnvironmentsListView({
        collection: denvsColl
      });
      this.listenTo(DSW, 'workspace:projectCard:nav:show', this.showProjectNav)
    },

    showProjectNav: function (view) {
      this.projectNav.show(view);
    },

    onShow: function () {
      this.listenTo(this.model.get('servers'), 'sync', function (o) {
        o.project = this.model;
        var serversView = new ServerListView({
          collection: o
        });
        var self = this;
        _.each(o.models, function (s) {
          s.set('project', self.model);
        });
        this.envs.show(this.environmentsView);
      });

      var servers = this.model.get('servers');
      servers.fetch();
    },

    onBeforeDestroy: function () {
      DSW.trigger('workspace:nav:close');
    }


  });

});
