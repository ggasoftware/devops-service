define([

'backbone', 'models/console/ConsoleMessage', 'App'

], function(Backbone, ConsoleMessage, App) {

  	'use strict';

    App.module('Collections.ConsoleMessages', function(ConsoleMessages) {

      ConsoleMessages = Backbone.Collection.extend({
        model : ConsoleMessage,
        initialize: function() {
          App.dlog('init ConsoleMessages collection', this);
        }
      });

      App.addInitializer(function() {
        App.Collections.ConsoleMessages._ = new ConsoleMessages();
      });

    });

});
