define([

  'jquery',
  'backbone',
  'marionette',

  'hbs!templates/user_dashboard/projects_list/list',

  'App',
  'models/Project',

  'views/user_dashboard/project/Project'

], function($, Backbone, Marionette, listTemplate, App, Project, ProjectView) {

  'use strict';

  return Backbone.Marionette.CompositeView.extend({

    template : listTemplate,
    childView : ProjectView,
    childViewContainer : '#projects-list',

    ui : {
      navTabs : '#nav-tabs',
      projectsList : '#projects-list',
      myProjectsTab : '#my-projects',
      allProjectsTab : '#all-projects'
    },

    events : {
      'keyup #projects-filter' : 'filter',
      'click @ui.myProjectsTab' : 'showMyProjects',
      'click @ui.allProjectsTab' : 'showAllProjects'
    },

    showMyProjects : function() {
      this.ui.navTabs.children().removeClass('active');
      this.ui.myProjectsTab.addClass('active');
      this.ui.projectsList.children().hide();
      this.ui.projectsList.children('.owner').fadeIn();
    },

    showAllProjects : function() {
      this.ui.navTabs.children().removeClass('active');
      this.ui.allProjectsTab.addClass('active');
      this.ui.projectsList.children().fadeIn();
    },

    onRender : function() {
      this.bindUIElements();
    },

    collectionEvents : {
      'models:unselect' : 'unselectedModels'
    },

    initialize : function() {
      this.listenTo(App.projects, 'sync', function() {
        console.log('sssync!');
        var sorted = _.sortBy(App.projects.models, function(m) {
          return m.get('id').toUpperCase();
        });
        this.collection.reset(sorted);
      });
    },

    unselectedModels : function() {
      this.ui.projectsList.children().removeClass('active');
    },

    filter : function(e) {
      var filterString = e.target.value;
      if (this.children.length !== 0) {
        _.each(this.children._views, function(v) {
          v.hideIfBingo(filterString);
        });
      }
    }

  });
});
