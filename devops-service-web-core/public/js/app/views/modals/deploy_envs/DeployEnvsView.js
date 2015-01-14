define([

  'jquery',

  'backbone',
  'marionette',

  'views/modals/deploy_envs/DeployEnvView',
  'hbs!templates/deploy_envs/container'

], function ($, Backbone, Marionette, DeployEnvView, DeployEnvsContainer) {

  'use strict';

  return Backbone.Marionette.CompositeView.extend({

    childView: DeployEnvView,
    childViewContainer: '.envs-container',
    template: DeployEnvsContainer,

    events: {
      'click #add-deploy-env': 'addDeployEnv',
      'click .delete-env': 'deleteUnsavedEnv'
    },

    addEnv: function () {
      this.collection.add({});
    },

    removeEnv: function (index) {
      this.collection.remove(this.collection.at(index));
    },

    initialize: function (options) {
      if(!options.collection) {
        this.collection = new Backbone.Collection([{}]);
      }
      this.collection.deps = options.deps;
    },

    addDeployEnv: function () {
      this.addEnv();
    },

    deleteUnsavedEnv: function (e) {
      var envPanel = $(e.target).closest('.env-properties');
      var index = this.$el.find('.env-properties').index(envPanel);
      this.removeEnv(index);
    }

  });

});
