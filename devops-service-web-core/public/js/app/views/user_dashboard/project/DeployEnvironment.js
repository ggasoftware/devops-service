define([

  'jquery',
  'hbs!templates/user_dashboard/project_card/env_card',
  'hbs!templates/user_dashboard/project_card/server_item',
  'hbs!templates/user_dashboard/project_card/no_servers',

  'backbone',
  'marionette',

  'App',
  'views/item/LoadingView'

], function ($, cardTemplate, serverTemplate, noServersTemplate, Backbone, Marionette, App, LoadingView) {

  'use strict';

  var ChildView = Marionette.ItemView.extend({

    template: serverTemplate,

    initialize: function () {
      this.on('reserved', this.reserved);
      this.on('unreserved', this.unreserved);
    },

    tagName: 'tr',

    className: function () {
      var reservedBy = this.model.get('modal').reserved_by;
      if (!!reservedBy) {
        return "success"
      }
    },

    templateHelpers: function () {
      var aLevels = App.request('get:accessLevels');
      var l3 = aLevels.level3();
      var l2 = aLevels.level2();
      return {
        accessLevels: {
          level2: l2,
          level3: l3
        }
      }
    },

    reserved: function () {
      this.$el.addClass('success');
    },

    unreserved: function () {
      this.$el.removeClass('success');
    },

    events: {
      "click #deploy-server": "deployServer",
      "click #reserve-server": "reserveServer",
      "click #unreserve-server": "unreserveServer",
      "click #pause-server": "pauseServer",
      "click #unpause-server": "unpauseServer",
      "click #delete-server": "deleteServer"
    },

    deployServer: function () {
      var deployEnv = this.model.get('modal').deploy_env;
      var user = App.request('get:currentUser');
      var canDeploy = this.model.get('project').checkUserPermissionsForEnv({user: user, deployEnv: deployEnv});
      if (canDeploy) {
        App.vent.trigger('server:deploy:start', {model: this.model});
      } else {
        App.trigger('alert:show', {
          type: 'danger',
          title: "",
          message: "Access denied. You don’t have permissions to deploy this server."
        });
      }
    },

    reserveServer: function () {
      this.model.attachedView = this;
      App.vent.trigger('server:reserve', {model: this.model});
    },

    unreserveServer: function () {
      this.model.attachedView = this;
      App.vent.trigger('server:unreserve', {model: this.model});
    },

    pauseServer: function () {
      App.vent.trigger('server:pause', {model: this.model});
    },

    unpauseServer: function () {
      App.vent.trigger('server:unpause', {model: this.model});
    },

    deleteServer: function () {
      App.vent.trigger('server:modal:delete', {model: this.model});
    }

  });

  var NoServersView = Backbone.Marionette.ItemView.extend({

    tagName: 'tr',
    template: noServersTemplate,

    templateHelpers: function () {
      return {
        accessLevels: App.request('get:accessLevels')
      }
    }

  });

  return Backbone.Marionette.CompositeView.extend({

    tagName: 'div',
    template: cardTemplate,

    emptyView: NoServersView,

    ui: {
      'deleteProject': '.delete-button',
      'createServer': '#create-server',
      'viewServers': '#view-servers',
      'manageUsers': '#env-users',
      'deployEnv': '#deploy-env'
    },

    events: {
      'click @ui.deleteProject': 'deleteProject',
      'click @ui.createServer': 'createServer',
      'click @ui.viewServers': 'viewServers',
      'click @ui.manageUsers': 'manageUsers',
      'click @ui.deployEnv': 'deployEnv',
      'click #bootstrap-server': 'bootstrapServer',
      'click .user-name': 'viewUser'
    },

    regions: {
      testRegion: '#test-region'
    },

    deployServer: function (e) {
    },

    childView: ChildView,
    childViewContainer: '#servers-container',

    initialize: function () {
      this.project = this.model.collection.project;
      this.model.set('project', this.project);
      var servers = this.model.get('project').getServersForEnv(this.model.get('identifier'));
      this.collection = new App.Collections.Servers.c(servers);
      this.model.set('servers', servers);
      this.model.set('accessLevels', App.request('get:accessLevels'));
      this.listenTo(App, 'project:removeServer:' + this.project.get('id'), this.onRemoveServer);
    },

    onRemoveServer: function (model) {
      this.collection.remove(model);
      console.log(this.collection);
    },

    templateHelpers: function () {
      var names, links, safe_links;

      names = this.model.get('users');
      links = _.map(names, function (name) {
        return "<a href='#' class='user-name'>" + name + "</a>";
      });
      safe_links = new Handlebars.SafeString(links.join(' '));

      return {
        usersWrapped: safe_links
      };
    },

    bootstrapServer: function () {
      App.vent.trigger('project:server:bootstrap', {model: this.model});
    },

    viewServers: function () {
      App.vent.trigger('viewServers', {env: this.model});
    },

    deployEnv: function () {
      console.log(this.model)
      var deployEnv = this.model.get('identifier');
      var user = App.request('get:currentUser');
      var canDeploy = this.model.get('project').checkUserPermissionsForEnv({user: user, deployEnv: deployEnv});
      if (canDeploy) {
        App.vent.trigger('project:environment:deploy', {model: this.model});
      } else {
        App.trigger('alert:show', {
          type: 'danger',
          title: "",
          message: "Access denied. You don’t have permissions to deploy this server."
        });
      }
    },

    createServer: function () {
      App.vent.trigger('requestCreateServer', {env: this.model, project: this.project});
    },

    manageUsers: function () {
      App.vent.trigger('manageEnvUsers', {env: this.model, project: this.project});
    },

    viewUser: function (e) {
      e.preventDefault();
      var userName = $(e.target).text();
      App.vent.trigger('user:info', {userName: userName});
    }

  });

});
