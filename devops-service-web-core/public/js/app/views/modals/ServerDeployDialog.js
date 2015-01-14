define([

  'jquery',
  'hbs!templates/modals/create_server/dialog',

  'backbone',
  'marionette',

  'App',
  'models/Image',
  'models/Server'

], function ($, modalTemplate, Backbone, Marionette, App) {

  'use strict';

  return Backbone.Marionette.CompositeView.extend({

    template: modalTemplate,
    tagName: 'div',
    className: 'modal fade in',

    events: {
      'click #deploy': 'startDeploy',
      'click #reserve-server': 'reserveServer'
    },

    reserveServer: function () {
      var data = {};
      this.model.attachedView = this;
      data.model = this.model;
      App.vent.trigger('server:reserve', data);
    },

    onServerDeployPending: function () {
      var label = this.$el.find('#result-label');
      label.addClass('alert-warning');
      label.html('<p><strong>Pending...</strong></p>');
    },

    onServerDeployStarted: function (res) {
      var resJSON = JSON.parse(res);

      if (resJSON.length > 0) {
        var resLink = resJSON[0];
        var label = this.$el.find('#result-label');

        label.removeClass('alert-warning');
        label.addClass('alert-success');

        label.html('<p><strong>Successfully started deploy! Report link:</strong></p>');
        label.append('<a class="report-link-wrapped" target=\'_blank\' href=\'' + resLink + '\'>' + resLink + '</a>');
      } else {
        label.addClass('alert-danger');
        label.html('<p><strong>Sorry. There’s no servers to deploy</strong></p>');
      }
    },

    onServerDeployFailed: function (r) {
      var responseStatus = r.status;

      var label = this.$el.find('#result-label');
      label.removeClass('alert-warning');

      if (responseStatus === 404) {
        label.addClass('alert-danger');
        label.html('<p>Sorry, deploy wasn\'t started.</p><p> It looks like you should reserve the server first..</p>' +
        '<p>You can <a style="cursor:pointer;" id="reserve-server">' +
        'reserve</a> this server and try again.</p>'
      )
        ;
      }

    },

    initEvents: function () {
      this.on('server:deploy:started', this.onServerDeployStarted);
      this.on('server:deploy:failed', this.onServerDeployFailed);
      this.on('reserved', this.reserved);
    },

    reserved: function () {
      var label = this.$el.find('#result-label');
      label.removeClass('alert-danger');
      label.addClass('alert-success');
      label.html('<p><strong>Successfully reserved server! Please try to deploy it again.</strong></p>');
    },

    startDeploy: function (e) {
      var deployButton = $(e.target);
      deployButton.attr('disabled', 'disabled');

      var that = this;
      this.onServerDeployPending();
      var sendData = {names: this.model.get('chef_node_name')};
      var url = App.reqres.request('url:get', '/server/deploy');
      var ajax = $.ajax({
        method: 'post',
        url: url,
        data: sendData
      });

      $.when(ajax).done(function (res) {
        that.trigger('server:deploy:started', res);
      })
        .fail(function (res) {
          that.trigger('server:deploy:failed', res);
        })
        .always(function () {
          deployButton.removeAttr('disabled');
        })
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
      this.model = data.model;
      this.render();
      this.$el.modal('toggle');
      this.initEvents();
    }

  });
});
