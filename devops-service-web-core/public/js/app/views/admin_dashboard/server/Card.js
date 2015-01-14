define([

  'jquery',

  'hbs!templates/admin_dashboard/server/card',

  'backbone',
  'marionette',

  'App',
  'util/quickJobHandler',
  'util/Redirector'

], function($, cardTemplate, Backbone, Marionette, App, quickJobHandler, Redirector) {

  'use strict';
  return Backbone.Marionette.ItemView.extend({

    tagName: 'div',
    template: cardTemplate,

    behaviors: {
      HasBackLink: {
        resourceName: 'servers'
      }
    },

    events: {
      "click .pause" : "pauseServer",
      "click .unpause" : "unpauseServer",
      "click .delete-button" : "deleteServer",
      "click .deployServer" : "deployServer"
    },

    onShow: function() {
      var server = this.model;
      var that = this;

      App.request('fetch', server);

      this.bindOnDestroyCallbacks();
    },

    bindOnDestroyCallbacks: function() {
      this.model.on('destroy', function() {
        App.request('refetch', [App.servers_common, App.servers_openstack, App.servers_chef, App.servers_ec2]);
        Redirector.redirect_to('admin/servers');
      });
    },

    pauseServer: function() {
      quickJobHandler.pauseServer(this.model);
    },

    unpauseServer: function() {
      quickJobHandler.unpauseServer(this.model);
    },

    deleteServer: function() {
      App.vent.trigger("server:deleteModal", {server: this.model});
    },

    deployServer: function() {
      alert("Sorry, this feature is not implemented yet for admin dashboard.");
      // if(confirm("Sure?")) {
/*        App.consoleRegion.show(new WebSocketView({*/
          //action: "/deploy",
          //data: {
            //names: this.model.attributes.chef_node_name,
          //},
          /*}));*/
      // }
    }
  });

});
