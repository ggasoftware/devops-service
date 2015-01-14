define([

  //libs
  'backbone',
  'marionette',

  //App
  'App'

  ], function(Backbone, Marionette, App) {

  'use strict';

  return Backbone.Marionette.Object.extend({

    initialize : function() {
      this.listenTo(App.vent, 'user:info', this.userInfo);
    },

    userInfo : function(data) {
      var moduleContainer = App.factory.getModule('modal', 'user:info');
      moduleContainer.promise.done(function() {
        var user = App.users.find(function(userModel) {
          return userModel.get('id') === data.userName;
        });
        new moduleContainer.module.clazz({
          user : user
        });
      });
    }

  });
});