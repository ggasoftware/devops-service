define([

  //libs
  'jquery',
  'backbone',
  'marionette',
  'underscore',

  //App
  'App',

  'views/modals/CreateServer',
  'views/modals/alert/DeleteServer',
  'views/modals/RunScriptModal',
  'util/longJobHandler',
  'util/quickJobHandler',
  'views/modals/ServerDeployDialog',
  'views/modals/ServerCreateDialog'

], function ($, Backbone, Marionette, _, App, CreateServerModal, DeleteServerAlert, RunScriptModal, longJobHandler, quickJobHandler, ServerDeployDialog, ServerCreateDialog) {

  'use strict';

  return Backbone.Marionette.Object.extend({

    initialize: function () {
      this.listenTo(App.vent, 'server:modal:delete', this.deleteServerModal);
      this.listenTo(App.vent, 'server:delete', this.deleteServer);
      this.listenTo(App.vent, 'server:create:start', this.createServerStart);
      this.listenTo(App.vent, 'server:modal:runScript', this.runScriptModal);
      this.listenTo(App.vent, 'server:script:run', this.runScript);
    },

    runScriptModal: function (data) {
      var moduleContainer = App.factory.getModule('modal', 'server:runScript');
      moduleContainer.promise.done(function () {
        new moduleContainer.module.clazz(data);
      });
    },

    runScript: function (data) {
      var promise = quickJobHandler.runScript(data);

      promise.done(function (o) {
        App.execute('console:success', o);
      });

      promise.fail(function (o) {
        App.execute('console:error', o.responseText);
      });

      promise.always(function () {
        data.client.trigger('promise:always');
      });

    },

    deleteServerModal: function (data) {
      new DeleteServerAlert({
        model: data.model
      });
    },

    //TODO refactor
    deleteServer: function (data) {
      var promise = quickJobHandler.deleteServer(data.model, data.removeByInstanceID);
      var model = data.model;

      var projectName = data.model.get('project').get('id');
      console.log(projectName);
      promise.done(function (o) {
        var message = JSON.parse(o).message;
        App.trigger('alert:show', {message: message});
        App.trigger('project:removeServer:' + projectName, data.model);
      });

      promise.fail(function (o) {
        var message = JSON.parse(o.responseText).message;
        App.trigger('alert:show', {type: 'danger', message: message});
      });

      promise.always(function () {
        data.client.trigger('promise:always');
      });
    },

    serverDeployDialog: function (data) {
      new ServerDeployDialog(data);
    },

    serverCreateDialog: function (data) {
      var parsed = JSON.parse(data);
      new ServerCreateDialog({
        url: parsed[0]
      });
    },

    createServerStart: function (data) {
      console.log(data);
      var requestBody = {
        project: data.data[0].value,
        deploy_env: data.data[1].value,
        name: (function () {
          if (data.data[2]) {
            return data.data[2].value
          }
          return undefined;
        }),
        without_bootstrap: (function () {
          if (data.data[3] !== undefined) {
            return data.data[3].value;
          } else {
            return false;
          }
        })()
      };

      var url = App.reqres.request('url:get', '/server/create');
      $.post(url, requestBody).done(function (res) {
        App.vent.trigger('server:create:started', res);
        data.client.trigger('server:create:started', res);
      }).fail(function (res) {
        App.vent.trigger('server:create:failed', res);
        data.client.trigger('server:create:failed', res);
      });
    },

    requestCreateServer: function (data) {
      new CreateServerModal({
        id: data.project.id,
        deploy_env: data.env.get('identifier'),
        project: data.project
      });
    },

    startCreateServerEnv: function (data) {
      longJobHandler.createServerDialog(data);
    },

    stopCreateServer: function (data) {
      data.waiter.setCreating(false);
      App.request('refetch', data.waiter.collection);
    },

    deployServer: function (data) {
      longJobHandler.startDeployServer({
        names: data.context.model.get('chef_node_name'),
        context: data.context
      });
    },

    startDeployServer: function (data) {
      data.context.model.setDeploying(true);
    },

    stopDeployServer: function (data) {
      data.waiter.setDeploying(false);
    },

    deleteModal: function (data) {

    },

    pauseServer: function (data) {
      quickJobHandler.pauseServer(data.server);
    },

    unpauseServer: function (data) {
      quickJobHandler.unpauseServer(data.server);
    },

    reserveServer: function (data) {
      var server = data.model;
      var urlString = '/server/' + server.get('chef_node_name') + '/reserve';
      var url = App.request('url:get', urlString);
      var ajax = $.ajax({
        url: url,
        method: 'post'
      });
      $.when(ajax).done(function (r) {
        var message = JSON.parse(r).message;
        var view = data.model.attachedView;
        App.trigger('alert:show', {message: message});
        view.trigger('reserved');
      }).fail(function (r) {
        var message = JSON.parse(r.responseText).message;
        App.trigger('alert:show', {type: 'danger', message: message});
      })
    },

    unreserveServer: function (data) {
      var urlString = '/server/' + data.model.get('chef_node_name') + '/unreserve';
      var url = App.request('url:get', urlString);
      var ajax = $.ajax({
        url: url,
        method: 'post'
      });
      $.when(ajax).done(function (r) {
        var message = JSON.parse(r).message;
        App.trigger('alert:show', {message: message});
        var view = data.model.attachedView;
        view.trigger('unreserved');
      }).fail(function (r) {
        var message = JSON.parse(r.responseText).message;
        App.trigger('alert:show', {type: 'danger', message: message});
      })
    }
  });
});
