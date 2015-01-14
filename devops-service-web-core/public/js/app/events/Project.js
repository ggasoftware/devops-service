define([

  'App',
  'util/longJobHandler',
  'util/quickJobHandler'

], function (App, longJobHandler, quickJobHandler) {

  'use strict';

  return Backbone.Marionette.Object.extend({

    initialize: function () {
      this.listenTo(App.vent, 'project:create', this.createProject);
      this.listenTo(App.vent, 'project:deploy:start', this.startDeployProject);
      this.listenTo(App.vent, 'project:environments:manage', this.manageEnvironments);
      this.listenTo(App.vent, 'project:environment:deploy', this.deployEnvironment);
      this.listenTo(App.vent, 'project:users:manage', this.manageUsers);
      this.listenTo(App.vent, 'project:modal:delete', this.deleteProjectModal);
      this.listenTo(App.vent, 'project:delete', this.deleteProject);
      this.listenTo(App.vent, 'project:info:show', this.showProjectInfo);
      this.listenTo(App.vent, 'project:server:bootstrap', this.bootstrapServer); //modal TODO - fix names
      this.listenTo(App.vent, 'project:server:bootstrap:start', this.startBootstrapServer); //start bootstrap process after server adding
      this.listenTo(App.vent, 'project:server:add', this.addServer);
    },

    startDeployProject: function (data) {
      require(['modules/DeployProject'], function (DeployProject) {
        DeployProject.start();
        DeployProject.showModal(data);
      });
    },

    manageUsers: function (data) {
      require(['modules/ManageUsers'], function (ManageUsers) {
        ManageUsers.start();
        ManageUsers.showModal(data);
      });
    },

    showProjectInfo: function (data) {
      require(['modules/ProjectInfo'], function (ProjectInfo) {
        ProjectInfo.start();
        ProjectInfo.showModal(data);
      })
    },

    deleteProjectModal: function (data) {
      require(['modules/DeleteProject'], function (DeleteProject) {
        DeleteProject.start();
        DeleteProject.showModal(data);
      });
    },

    addServer: function (data) {
      var sendData = {
        private_ip: data.formData[0].value,
        remote_user: data.formData[2].value,
        key: data.formData[3].value,
        project: data.model.get('project').get('id'),
        deploy_env: data.model.get('identifier')
      };

      var bootstrapTemplate = data.formData[1].value;
      var nodeName = data.formData[4].value;

      var url = App.request('url:get', '/server/add');
      var promise = $.ajax({
        method: 'post',
        url: url,
        data: sendData
      });

      promise.done(function (res) {
        data.client.trigger('project:server:add:success', res, nodeName, bootstrapTemplate);
      });
      promise.fail(function (res) {
        data.client.trigger('project:server:add:error', res);
      });

    },

    startBootstrapServer: function (data) {
      var sendData = {
        instance_id: data.serverID,
        name: data.nodeName
      };

      var url = App.request('url:get', '/server/bootstrap');
      var promise = $.ajax({
        method: 'post',
        url: url,
        data: sendData
      });

      promise.done(function (res) {
        data.client.trigger('project:server:bootstrap:success', res);
      });
      promise.fail(function (res) {
        data.client.trigger('project:server:bootstrap:error', res);
        console.log(res);
      });

    },

    deployEnvironment: function (data) {
      require(['modules/StartDeployEnvironment'], function (StartDeployEnvironment) {
        StartDeployEnvironment.start();
        StartDeployEnvironment.showModal(data);
      });
    },

    createProject: function () {
      require(['modules/CreateProject'], function (CreateProject) {
        CreateProject.start();
        CreateProject.showModal();
      })
    },

    bootstrapServer: function (data) {
      require(['modules/BootstrapServer'], function (BootstrapServer) {
          BootstrapServer.start();
          BootstrapServer.showModal(data);
      });
    },

    manageEnvironments: function (data) {
      require(['modules/ManageEnvironments'], function (ManageEnvironments) {
        ManageEnvironments.start();
        ManageEnvironments.showDialog(data);
      });
    },

    //TODO refactor
    deleteProject: function (data) {
      var promise = quickJobHandler.deleteProject(data.model);

      promise.done(function (o) {
        var message = JSON.parse(o).message;
        App.trigger('alert:show', {message: message});
        App.trigger('workspace:nav:close');
        console.log(App.projectNavbarRegion);
        require(['modules/ProjectsList'], function (ProjectsList) {
          ProjectsList.start();
          ProjectsList.showProjectsList();
        })
      });

      promise.fail(function (o) {
        var message = JSON.parse(o.responseText).message;
        App.trigger('alert:show', {type: 'danger', message: message})
      });

      promise.always(function () {
        data.client.trigger('promise:always');
      });
    }

  });
});
