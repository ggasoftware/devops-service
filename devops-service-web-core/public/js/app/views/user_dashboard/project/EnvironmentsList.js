define([

  'jquery',

  'backbone',
  'marionette',

  'views/user_dashboard/project/DeployEnvironment',
  'collections/DeployEnvironments',
  'hbs!templates/user_dashboard/project_card/env_container'

], function($, Backbone, Marionette, DeployEnvironment, DeployEnvironments, containerTemplate) {

  'use strict';

  return Backbone.Marionette.CompositeView.extend({

    template : containerTemplate,

    childView : DeployEnvironment,
    childViewContainer : '#envs-container',

    onDestroy : function() {
      this.stopListening();
    }

  });
});
