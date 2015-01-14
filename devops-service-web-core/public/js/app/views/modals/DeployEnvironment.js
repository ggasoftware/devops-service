define([

  'jquery',
  'hbs!templates/modals/deploy_project_env/modal',

  'backbone',
  'marionette',

  'App',
  'models/Image',
  'models/Server'

], function ($, modalTemplate, Backbone, Marionette, App, Image, Server) {

  'use strict';

  return Backbone.Marionette.CompositeView.extend({

    template: modalTemplate,
    tagName: 'div',
    className: 'modal fade in',

    events: {
      'click #deploy': 'startDeploy'
    },

    onDeployPending: function () {
      var label = this.$el.find('#result-label');
      label.addClass('alert-warning');
      label.html('<p><strong>Pending...</strong></p>');
    },

    onDeployStarted: function (res) {
      var label = this.$el.find('#result-label');
      label.removeClass('alert-warning');

      var resJSON = JSON.parse(res);
      if (resJSON.length > 0) {

        label.addClass('alert-success');

        label.html('<p><strong>Successfully started deploy! Report link:</strong></p>');
        _.each(resJSON, function (link) {
          label.append('<p><a class="report-link-wrapped" target=\'_blank\' href=\'' + link + '\'>' + link + '</a></p>');
        });
      } else {
        label.addClass('alert-danger');
        label.html('<p><strong>Sorry. There’s no servers to deploy</strong></p>');
      }
    },

    onProjectEnvironmentDeployFailed: function (res) {
      var label = this.$el.find('#result-label');
      label.addClass('alert-danger');

      label.removeClass('alert-warning');
      label.html('<p><strong>Failed deploying project!</strong></p>');
    },

    initEvents: function () {
      this.on('project:environment:deploy:started', this.onDeployStarted);
      this.on('project:environment:deploy:failed', this.onDeployFailed);
    },

    startDeploy: function (e) {
      var deployButton = $(e.target);
      deployButton.attr('disabled', 'disabled');

      var that = this;
      this.onDeployPending();
      var url = App.request('url:get', '/project/' + this.model.get('project').get('id') + '/deploy');
      var sendData = {
        deploy_env: this.model.get('identifier')
      };
      var ajax = $.ajax({
        method: 'post',
        url: url,
        data: sendData
      });

      $.when(ajax)
        .done(function (res) {
          that.trigger('project:environment:deploy:started', res);
        })
        .fail(function (res) {
          that.trigger('project:environment:deploy:failed', res);
        });
    },

    templateHelpers: function () {
      var that = this;
      return {
        url: function () {
          return that.options.url;
        }
      };
    },

    initialize: function (data) {
      console.log(data);
      this.model = data.model;
      this.render();
      this.$el.modal('toggle');
      this.initEvents();
    }

  });
});
