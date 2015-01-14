define([

'backbone',
'marionette'

], function(Backbone) {

  'use strict';

  return Backbone.Marionette.AppRouter.extend({
    appRoutes : {
      'settings' : 'index'
    }
  });

});