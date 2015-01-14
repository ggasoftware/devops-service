define([

  'jquery',
  'hbs!templates/modals/create_server/modal',

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
      'click #create-server': 'createServer',
      'click .sendCollection': 'sendData'
    },

    initialize: function (data) {
      this.initEvents();
      this.model = new Backbone.Model({project_id: data.id, deploy_env: data.deploy_env});
      this.project = data.project;
      this.render();
      this.$el.modal('toggle');
    },

    templateHelpers: function () {
      return {
        accessLevels: App.request('get:accessLevels')
      }
    },

    initEvents: function () {
      this.on('server:create:started', this.onServerCreateStarted);
      this.on('server:create:failed', this.onServerCreateFailed);
    },

    onServerCreatePending: function () {
      var label = this.$el.find('#result-label');
      label.addClass('alert-warning');

      label.html('<p><strong>Pending...</strong></p>');
    },

    onServerCreateStarted: function (res) {
      var resJSON = JSON.parse(res);
      var resLink = resJSON[0];
      var label = this.$el.find('#result-label');

      label.removeClass('alert-warning');
      label.addClass('alert-success');

      label.html('<p><strong>Successfully launched server! Report link:</strong></p>');
      label.append('<a class="report-link-wrapped" target=\'_blank\' href=\'' + resLink + '\'>' + resLink + '</a>');
    },

    onServerCreateFailed: function () {
      var label = this.$el.find('#result-label');
      label.addClass('alert-danger');

      label.removeClass('alert-warning');
      label.html('<p><strong>Failed creating server!</strong></p>');
    },

    createServer: function () {
      this.$el.find('#create-server').attr('disabled', 'disabled');
      var tmpServer = new Server({chef_node_name: 'new server'});
      this.project.get('servers').add(tmpServer);
      var formData = this.$el.find('form#properties').serializeArray();
      this.onServerCreatePending();
      App.vent.trigger('server:create:start', {
        context: {model: tmpServer},
        data: formData,
        project: this.project,
        client: this
      });
    }

  });
});
