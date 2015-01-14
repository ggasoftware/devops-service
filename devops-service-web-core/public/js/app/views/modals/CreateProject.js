define([

  'jquery',

  'hbs!templates/modals/create_project/modal',

  'backbone',
  'marionette',

  'App',
  'views/modals/deploy_envs/DeployEnvsView',
  'util/quickJobHandler',
  'views/item/AlertView',
  'models/Project',
  'backbone.syphon'


], function ($, modalTemplate, Backbone, Marionette, App, DeployEnvsView, quickJobHandler, AlertView, ProjectModel) {

  'use strict';
  return Backbone.Marionette.LayoutView.extend({

    template: modalTemplate,
    //tagName: 'div',
    //className: 'modal fade in',

    regions: {
      deploy_envs: '#create-project-deploy-envs'
    },

    events: {
      'click .sendCollection': 'sendData'
    },

    initialize: function (data) {
      console.log(data);
      this.deps = data.deps;
      this.type = data.type;
      this.render();
      //this.$el.modal('toggle');
    },

    onShow: function () {
      this.deploy_envs.show(new DeployEnvsView({deps: this.deps}));
    },

    sendData: function () {
      var data = Backbone.Syphon.serialize(this);
      this.sendingData = data;
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
        var runListArray = d.run_list[0].split(",");
        if (d.users[0] === null || d.users[0] === "") {
          d.users = undefined;
        }
        d.run_list = runListArray;
        if (d.run_list[0] === "") {
          d.run_list = undefined;
        }

      });

      var createButton = this.$el.find('#create-button')
      createButton.button('loading');
      var self = this;
      var baseUrl = (function() {
        if (self.type === 'request') { return '/request' };
        if (self.type === 'new') { return '/project' };
      })();

      console.log('baseUrl: ', baseUrl);

      var url = App.request('url:get', baseUrl);
      var promise = $.ajax(url, {
        data: JSON.stringify(data),
        contentType: "application/json; charset=utf-8",
        method: 'post',
        dataType: 'json'
      });

      promise.always(function () {
        createButton.button('reset');
      });

      promise.done(function (r) {
        if (self.type === 'new') {
          App.trigger('workspace:project:show', {model: new ProjectModel({id: data.name})})
        }
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
