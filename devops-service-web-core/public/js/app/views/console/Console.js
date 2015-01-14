define([

  'jquery',
  'backbone',
  'marionette',

  'App',

  'hbs!templates/console/container',

  'views/console/ConsoleMessages',
  'views/console/ConsoleTabs',

  'jqueryui'

], function($, Backbone, Marionette, App, containerTemplate, ConsoleMessagesView, ConsoleTabsView) {

  'use strict';

  return Backbone.Marionette.LayoutView.extend({

    template : containerTemplate,

    regions : {
      messagesRegion : '#messages',
      tabsRegion : '#tabs-container'
    },

    ui : {
      clearConsole : '#clear-console',
      showHide : '#show-hide'
    },

    events : {
      'click @ui.clearConsole' : 'clearConsole',
      'click @ui.showHide' : 'showHide'
    },

    initialize : function(options) {
      this.initConsoleCollection(options.consoles);
      this.initTabsView();
      this.initEvents();
    },

    initConsoleCollection : function(coll) {
      this.consoles = coll;
    },

    initTabsView : function() {
      this.consoleTabsView = new ConsoleTabsView({
        collection : this.consoles
      });
    },

    initEvents : function() {
      this.listenTo(this.consoleTabsView, 'setActiveTab', this.setActiveConsole);
    },

    onShow : function() {
      this.messagesRegion.show(new ConsoleMessagesView());
      this.setActiveConsole(this.consoles.at(0)); // switch to main console
      this.tabsRegion.show(this.consoleTabsView);
      this.delegateEvents();
      this.initResizable();
      this.adjustWorkspaceHeight();
      $(window).resize(this.adjustWorkspaceHeight);
    },

    setActiveConsole : function(consoleModel) {
      this.consoles.deactivateTabs();
      consoleModel.setActive();
      this.messagesRegion.currentView.setActiveConsole(consoleModel);
    },

    clearConsole : function() {
      this.messagesRegion.currentView.collection.reset();
    },

    showHide : function() {
      var consoleContainer = $('#console');
      consoleContainer.toggleClass('collapsed');
      var newButtonText = consoleContainer.hasClass('collapsed') ? 'Show' : 'Hide';
      this.ui.showHide.text(newButtonText);
      this.adjustWorkspaceHeight();
    },

    adjustWorkspaceHeight : function() {
      var navbarHeight = $('#navbar .navbar').height();
      var consoleHeight = $('#console').height();
      var workspaceHeight = $(window).height() - navbarHeight - consoleHeight;
      $('#workspace').height(workspaceHeight);
      $('#console #messages').height(consoleHeight - $('#navbar .navbar-nav').height() - 34);
    },

    initResizable : function() {
      var that = this;
      var currentHeight = $('#console').height();
      $('#console').resizable({
        handles : 'n',
        helper : 'resizable-helper',
        minHeight : currentHeight,
        stop : function() {
          that.adjustWorkspaceHeight();
        }
      });
    }

  });
});