define([

  'App',
  'events/Script'

], function (App, ScriptEventHandler) {
  
  'use strict';

  return {
    initEvents: function () {
      App.vent.on('script:add', function() {
        ScriptEventHandler.showAddScriptModal();
      });

      App.vent.on('script:delete', function(data) {
        ScriptEventHandler.showDeleteScriptModal(data);
      });

      App.vent.on('script:delete:success', function(data) {
        ScriptEventHandler.showScriptsList(data);
      });

    }
  };

});