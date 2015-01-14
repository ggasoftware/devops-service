define([

  'jquery',
  'hbs!templates/modals/bootstrap_server/modal',

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
      "click #bootstrap-server": "bootstrapServer",
      "change #input-ip": "onInputIPChange"
    },

    onInputIPChange: function (e) {
      var ipRegExp = /\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b/;
      var inputValue = e.target.value;
      var isIP = inputValue.match(ipRegExp);
      if (isIP === null) {
        var inputValueChunk = inputValue.split('.')[0];
        var inputNodeName = this.$el.find('#input-chef-node-name');
        inputNodeName.val(inputValueChunk);
      }
    },

    initialize: function (data) {
      this.initEvents();
      console.log(data);
//      this.model = data.model;
      this.render();
      this.$el.modal('toggle');
    },

    initEvents: function () {
      this.on("project:server:add:success", this.onServerAddSuccess);
      this.on("project:server:bootstrap:error", this.onServerBootstrapError);
      this.on("project:server:bootstrap:success", this.onServerBootstrapSuccess);
    },

    onServerBootstrapError: function (res) {
      var message = res.responseText;
      var label = this.$el.find("#result-label");

      label.removeClass('alert-success');
      label.addClass('alert-danger');

      label.append("<p><strong>" + message + "</strong></p>");
    },

    onServerBootstrapSuccess: function (res) {
      var resJSON = JSON.parse(res);
      var resLink = resJSON[0];
      var label = this.$el.find("#result-label");

      label.removeClass('alert-warning');
      label.addClass('alert-success');

      label.append("<p><strong>Successfully started bootstrap! Report link:</strong></p>");
      label.append("<a class=\"report-link-wrapped\" target=\"_blank\" href=\"" + resLink + "\">" + resLink + "</a>");
    },

    onServerAddSuccess: function (res, nodeName, bootstrapTemplate) {
      var resJSON = JSON.parse(res);
      var resMessage = resJSON.message;
      var serverID = resJSON.message.split("'")[1];
      var label = this.$el.find("#result-label");
      label.addClass('alert-success');
      label.html("<p><strong>" + resMessage + "</strong></p>");
      label.append("<p>starting bootstrap...</p>");
      this.startBootstrap(serverID, nodeName, bootstrapTemplate);
    },

    startBootstrap: function (serverID, nodeName, bootstrapTemplate) {
      var self = this;
      App.vent.trigger("project:server:bootstrap:start", {
        serverID: serverID,
        nodeName: nodeName,
        bootstrapTemplate: bootstrapTemplate,
        client: self
      });
    },

    onServerCreatePending: function () {
      var label = this.$el.find("#result-label");
      label.addClass('alert-warning');
      label.html("<p><strong>Pending...</strong></p>");
    },

    onServerCreateStarted: function (res) {
      var resJSON = JSON.parse(res);
      var resLink = resJSON[0];
      var label = this.$el.find("#result-label");

      label.removeClass('alert-warning');
      label.addClass('alert-success');

      label.html("<p><strong>Successfully launched server! Report link:</strong></p>");
      label.append("<a target=\"_blank\" href=\"" + resLink + "\">" + resLink + "</a>");
    },

    onServerCreateFailed: function () {
      var label = this.$el.find("#result-label");
      label.addClass('alert-danger');

      label.removeClass('alert-warning');
      label.html("<p><strong>Failed creating server!</strong></p>");
    },

    bootstrapServer: function (e) {
      var button = $(e.target);
      button.attr('disabled', 'disabled');
      var form = this.$el.find('form');
      var disabled = form.find(':input:disabled').removeAttr('disabled');
      var formData = form.serializeArray();
      disabled.attr('disabled', 'disabled');
      //this.onServerBootstrapPending();
      var self = this;
      App.vent.trigger("project:server:add", {
        formData: formData,
        model: this.model,
        client: self
      });
    }

  });
});
