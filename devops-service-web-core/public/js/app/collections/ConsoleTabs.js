define ([

  'backbone',

  'models/console/Console'

],  function(Backbone, Console) {

  'use strict';

  App.module('Collections.ConsoleTabs', function(ConsoleTabs) {

    ConsoleTabs = Backbone.Collection.extend({
      model : Console,

      write : function(msg, type, tag) {
        var targetConsole = this.findWhere({
        tag : tag
        });
        if (!targetConsole) {
        targetConsole = new Console({
          tag : tag,
          isCloseable : true
        });
        this.add(targetConsole);
        }
        targetConsole.write(msg, type);
      },

      deactivateTabs : function() {
        _.each(this.models, function(tabModel) {
        tabModel.set('active', false);
        });
      }

    });

    App.addInitializer(function() {
      App.Collections.ConsoleTabs._ = new ConsoleTabs();
    });

  });

});
