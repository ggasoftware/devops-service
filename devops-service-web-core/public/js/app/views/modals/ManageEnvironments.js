define([

  'jquery',

  'hbs!templates/modals/add_envs/modal',

  'backbone',
  'marionette',

  'App',
  'views/modals/deploy_envs/DeployEnvsView',
  'collections/DeployEnvironments',
  'backbone.syphon',
  'views/item/AlertView'

], function ($, modalTemplate, Backbone, Marionette, App, DeployEnvsView, DeployEnvironments, Syphone, AlertView) {

  'use strict';

  return Backbone.Marionette.LayoutView.extend({

    template: modalTemplate,

    events: {
      'click .save-envs-button': 'sendData',
      'click .show-project-button': 'showProject',
      'submit form': 'formSubmitted'
    },

    formSubmitted: function (e) {
    },

    regions: {
      deploy_envs: '.env-properties'
    },

    showProject: function () {
      App.vent.trigger('userLayout', 'project:show', this.model.get('id'));
    },

    initialize: function (data) {
      this.deps = data.deps;
      this.initEvents();
      this.project_id = data.model.get('id');
      this.model = data.model;
      this.render();
    },

    onShow: function () {
      var deployEnvs = this.model.get('deploy_envs');
      var envsCollection = new DeployEnvironments(deployEnvs);
      var envsView = new DeployEnvsView({collection: envsCollection, deps: this.deps});
      this.deploy_envs.show(envsView);
    },

    initEvents: function () {
      this.on('deps:fetched', function () {
        console.log('deps fetched');
      });
    },

    serializeData: function () {
      return {project_id: this.project_id};
    },

    sendData: function () {
      var saveButton = this.$el.find('.save-envs-button');
      saveButton.button('loading');
      //var formData = this.$el.find('form').serializeArray();
      //var that = this;
      var data = Backbone.Syphon.serialize(this);
      data.deploy_envs = _.toArray(data.deploy_envs);
      _.each(data.deploy_envs, function (d) {
        if (d.expires === "") {
          d.expires = undefined;
        }
        if (d.groups[0] === null) {
          d.groups = undefined;
        }
        if (d.subnets[0] === null) {
          d.subnets = undefined;
        }

        var usersArray = d.users[0].split(",");
        var usersArray = _.map(usersArray, function (u) {
          return $.trim(u);
        });
        d.users = usersArray;
        if(d.users[0] === null || d.users[0] === ""){
          d.users = undefined;
        }

        var runListArray = d.run_list[0].split(",");
        d.run_list = runListArray;
        if(d.run_list[0] === null || d.run_list[0] === ""){
          d.run_list = undefined;
        }
      });

      var stringifiedData = JSON.stringify(data);

      var url = App.request('url:get', '/project');

      var promise = $.ajax(url, {
        data: JSON.stringify(data),
        contentType: "application/json; charset=utf-8",
        method: 'put',
        dataType: 'json'
      });

      promise.always(function () {
        saveButton.button('reset');
      });

      promise.done(function (r) {
        var view = new AlertView({
          message: r.message,
          type: "success"
        });
        App.alertRegion.show(view);
      });

      promise.fail(function (r) {
        var message = JSON.parse(r.responseText).message;
        var view = new AlertView({
          message: message,
          type: "danger"
        })
        App.alertRegion.show(view);
      });
    }

  });
});
