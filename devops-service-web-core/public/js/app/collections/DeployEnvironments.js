define([

  'App',
  'models/DeployEnv'

], function (DSW, DeployEnvironment) {

  'use strict';

  return Backbone.Collection.extend({
    model: DeployEnvironment,
    initialize: function () {
      DSW.dlog('init DeployEnvironments collection', this);
    },

    parse: function (r) {
      return r;
    }

  });

});
