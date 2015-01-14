define([

  'jquery',
  'backbone',
  'marionette',

  'hbs!templates/user_dashboard/reports/container',
  'hbs!templates/user_dashboard/reports/item',
  'hbs!templates/user_dashboard/reports/no-reports',

  'App'

], function ($, Backbone, Marionette, containerTemplate, itemTemplate, noReportsTemplate, App) {

  'use strict';

  var EmptyView = Backbone.Marionette.ItemView.extend({

    template: noReportsTemplate,
    tagName: 'tr'
  
  });

  var RecordView = Backbone.Marionette.ItemView.extend({
    template: itemTemplate,
    tagName: 'tr',

    hideIfBingo : function(filterStringProjects, filterStringUsers, filterStringTypes, filterStringEnvs, c, f, p) {

      var sub1 = this.model.get('project').toLowerCase();
      var sub2 = this.model.get('createdBy').toLowerCase();
      var sub3 = this.model.get('type').toLowerCase();
      var s = this.model.get('status');
      var sub4 = null;
      var sub5 = this.model.get('deployEnv').toLowerCase();

      if(s === 'completed') { sub4 = c};
      if(s === 'failed') { sub4 = f};
      if(s === 'running') { sub4 = p};

      if (sub1.indexOf(filterStringProjects) !== -1 && sub2.indexOf(filterStringUsers) !== -1 && sub3.indexOf(filterStringTypes) !== -1 && sub5.indexOf(filterStringEnvs) !== -1 && sub4) {
        $(this.el).show();
      } else {
        $(this.el).hide();
      }
    },

    templateHelpers: function () {
      var self = this;
      return {
        linkPrefix: function () {
          return App.request('get:serviceHostname') + '/services/cid/v2.0/report/'
        }
      }
    },

    className: function () {
      var status = this.model.get('status');
      if (status === 'completed') {
        return 'success';
      }
      if (status === 'failed') {
        return 'danger';
      }
      if (status === 'running') {
        return 'warning';
      }
    }
  });

  return Backbone.Marionette.CompositeView.extend({

    template: containerTemplate,
    childView: RecordView,
    childViewContainer: '#reports-list',
    emptyView: EmptyView,

    events: {

      'keyup #projects-filter': 'filter',
      'click #projects-filter': 'filter',

      'keyup #users-filter': 'filter',
      'click #users-filter': 'filter',

      'keyup #type-filter': 'filter',
      'click #type-filter': 'filter',

      'keyup #env-filter': 'filter',
      'click #env-filter': 'filter',

      'click #filter-completed':'filter',
      'click #filter-failed':'filter',
      'click #filter-in-progress':'filter'

    },

    filter: function() {
      var c = this.$el.find('#filter-completed').prop('checked');
      var f = this.$el.find('#filter-failed').prop('checked');
      var p = this.$el.find('#filter-in-progress').prop('checked');

      var inputFieldProjects = this.$el.find('#projects-filter');
      var inputFieldUsers = this.$el.find('#users-filter');
      var inputFieldTypes = this.$el.find('#type-filter');
      var inputFieldEnvs = this.$el.find('#env-filter');

      var filterStringProjects = inputFieldProjects.val().toLowerCase();
      var filterStringUsers = inputFieldUsers.val().toLowerCase();
      var filterStringTypes = inputFieldTypes.val().toLowerCase();
      var filterStringEnvs = inputFieldEnvs.val().toLowerCase();

      if (this.children.length !== 0) {
        _.each(this.children._views, function (v) {
          v.hideIfBingo(filterStringProjects, filterStringUsers, filterStringTypes, filterStringEnvs, c, f, p);
        });
      }
    },

    templateHelpers: function () {
      return {
        //summary : {
        //  failed : App.reportRecords.getFailed().length,
        //  completed : App.reportRecords.getPassed().length,
        //  running: App.reportRecords.getRunning().length
        //}
      }
    }

  });
});
