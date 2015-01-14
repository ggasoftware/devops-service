define([

  'App'

],  function (App) {

  	'use strict';
    return {
      initEvents: function() {

        App.commands.setHandler('console:default', function(message, tag) {
//          App.consoles.write(message, 'default', tag || 'Main');
        });

        App.commands.setHandler('console:success', function(message, tag) {
 //         App.consoles.write(message, 'ok', tag || 'Main');
        });

        App.commands.setHandler('console:error', function(message, tag) {
        //  App.consoles.write(message, 'err', tag || 'Main');
        });

        App.commands.setHandler('console:info', function(message, tag) {
      //    App.consoles.write(message, 'info', tag || 'Main');
        });

        App.commands.setHandler('console:debug', function(message, tag) {
       //   App.consoles.write(message, 'dbug', tag || 'Main');
        });

      }
    };

});
