define([

  'jquery',
  'backbone',
  'marionette',

  'hbs!templates/user_dashboard/projects_list/list',

  'App',
  'models/Project',

  'views/user_dashboard/project/Project'

], function ($, Backbone, Marionette, listTemplate, App, Project, ProjectView) {

  'use strict';

  return Backbone.Marionette.CompositeView.extend({

    template: listTemplate,
    childView: ProjectView,
    childViewContainer: '#projects-list',

    ui: {
      navTabs: '#nav-tabs',
      projectsList: '#projects-list',
      myProjectsTab: '#my-projects',
      allProjectsTab: '#all-projects'
    },

    events: {
      'keyup #projects-filter': 'filter',
      'click #projects-filter': 'filter',
      'click @ui.myProjectsTab': 'showMyProjects',
      'click @ui.allProjectsTab': 'showAllProjects'
    },

    showMyProjects: function () {
      this.ui.navTabs.children().removeClass('active');
      this.ui.myProjectsTab.addClass('active');
      var projectsList = this.$el.find('#projects-list');
      var children = projectsList.children('.owner');
      if (children.length > 0) {
        this.ui.projectsList.children().hide();
        this.ui.projectsList.children('.owner').fadeIn();
        this.showingMy = true;
        this.filter();
      } else {
        projectsList.append('<tr class="no-projects"><td><div class="text-center">You’re not registered in any CID projects yet.</div></br></td></tr>');
        $('#projects-list tr').not('.no-projects').hide();
      }
    },

    showAllProjects: function () {
      this.ui.navTabs.children().removeClass('active');
      this.ui.allProjectsTab.addClass('active');
      this.ui.projectsList.children('.no-projects').remove();
      this.ui.projectsList.children().fadeIn();
      this.showingMy = false;
      this.filter();
    },

    collectionEvents: {
      'models:unselect': 'unselectedModels'
    },

    initialize: function () {
      var sorted = _.sortBy(this.collection.models, function (m) {
        return m.get('id').toUpperCase();
      });
      this.collection.reset(sorted);
      this.bindUIElements();
    },

    onRender: function () {
      this.$el.fadeIn();
    },

    onShow: function () {
      this.showAllProjects();
/*      var childrenLength  = this.ui.projectsList.children('.owner').length;*/
      //if (childrenLength > 0) {
        //this.showMyProjects();
      //} else {
        //this.showAllProjects();
      /*}*/
    },

    unselectedModels: function () {
      this.ui.projectsList.children().removeClass('active');
    },

    onBeforeDestroy: function () {
      App.sidebarInfoRegion.empty();
    },

    filter: function () {
      var self = this;
      var inputField = this.$el.find('#projects-filter');
      var filterString = inputField.val().toLowerCase();
      if (this.children.length !== 0) {
        _.each(this.children._views, function (v) {
          v.hideIfBingo(filterString, self.showingMy);
        });
      }
    }

  });
});
