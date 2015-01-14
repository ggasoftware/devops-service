define([

  'App',
  'jquery',
  'backbone'

], function(App, $, Backbone) {

  'use strict';

  return Backbone.Model.extend({
    urlRoot: App.request('url:get', '/models/flavor'),
    rowTemplate: '#flavor-row-template',

    parse: function(res) {
      return {
        disk: res.disk,
        ram: res.ram,
        v_cpus: res.v_cpus,
        id: res.id,
        displayName: res.id,
        keyName: res.id,
        name: res.name,
        cores: res.cores
      };
    }
  });

});
