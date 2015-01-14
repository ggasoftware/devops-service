define([

  'App',
  'events/Server'

], function(App, ServerEventHandler) {

  'use strict';

  return {
    initEvents : function() {

      var serverEventHandler = new ServerEventHandler();

      App.vent.on('server:deploy:start', function(data) {
        serverEventHandler.serverDeployDialog(data);
      });

      App.vent.on('server:create:started', function() {
        //        ServerEventHandler.serverCreateDialog(data);
      });

      App.vent.on('requestCreateServer', function(data) {
        serverEventHandler.requestCreateServer(data);
      });

      App.vent.on('startCreateServer', function(data) {
        serverEventHandler.startCreateServerEnv(data);
      });

      App.vent.on('stopCreateServer', function(data) {
        serverEventHandler.stopCreateServer(data);
      });

      App.vent.on('requestDeployServer', function(data) {
        if (confirm('Sure?')) {
          serverEventHandler.deployServer(data);
        }
      });

      App.vent.on('startDeployServer', function(data) {
        serverEventHandler.startDeployServer(data);
      });

      App.vent.on('stopDeployServer', function(data) {
        serverEventHandler.stopDeployServer(data);
      });

      App.vent.on('pauseServer', function(data) {
        serverEventHandler.pauseServer(data);
      });

      App.vent.on('unpauseServer', function(data) {
        serverEventHandler.unpauseServer(data);
      });

      App.vent.on('server:reserve', function(data) {
        serverEventHandler.reserveServer(data);
      });

      App.vent.on('server:unreserve', function(data) {
        serverEventHandler.unreserveServer(data);
      });

      App.vent.on('server:requestRunScript', function(data) {
        serverEventHandler.showRunScriptModal(data);
      });

    }
  };

});
