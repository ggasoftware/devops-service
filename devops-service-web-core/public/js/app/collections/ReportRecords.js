define([

  'backbone',

  'models/ReportRecord',

  'App'

], function (Backbone, ReportRecord, App) {

  'use strict';

  return Backbone.Collection.extend({
    model: ReportRecord,

    url: function () {
      return App.request('url:get', '/api/reports/' + this.date );
    },

    initialize: function (opts) {
      this.date = opts.date;
    },

    getFailed: function () {
      var mapped = _.filter(this.models, function (m) {
        return m.get('status') === 'failed';
      });
      return mapped;
    },

    getPassed: function () {
      var mapped = _.filter(this.models, function (m) {
        return m.get('status') === 'completed';
      });
      return mapped;
    },

    getRunning: function () {
      var mapped = _.filter(this.models, function (m) {
        return m.get('status') === 'running';
      });
      return mapped;
    }

  });

});


