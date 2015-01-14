define([

  'jquery',

  'hbs!templates/admin_dashboard/server/row_common',
  'hbs!templates/admin_dashboard/server/row_openstack',
  'hbs!templates/admin_dashboard/server/row_chef',
  'hbs!templates/admin_dashboard/server/row_ec2',

  'hbs!templates/admin_dashboard/server/table_common',
  'hbs!templates/admin_dashboard/server/table_openstack',
  'hbs!templates/admin_dashboard/server/table_chef',
  'hbs!templates/admin_dashboard/server/table_ec2',

  'backbone',
  'marionette',

  'App',
  'views/admin_dashboard/server/Create'

], function($, row_common, row_openstack, row_chef, row_ec2, table_common, table_openstack, table_chef, table_ec2, Backbone, Marionette, App, CreateView) {

  'use strict';

  var ServerView = Backbone.Marionette.ItemView.extend({
    tagName : 'tr',
    template : row_common,

    behaviors : {
      CardShowable : {
        resourceName : 'servers'
      }
    }
  });

  var ServerViewOpenstack = ServerView.extend({
    template : row_openstack
  });

  var ServerViewChef = ServerView.extend({
    template : row_chef
  });

  var ServerViewEC2 = ServerView.extend({
    template : row_ec2
  });

  return Backbone.Marionette.CompositeView.extend({

    template : table_common,
    childView : ServerView,
    childViewContainer : 'tbody',
    tagName : 'table',
    className : 'table table-responsive table-striped tab-pane',

    behaviors : {
      Refetchable : {}
    },

    events : {
      'click .openCreateDialog' : 'openCreateDialog',
      'click .pill-common' : 'filterCommon',
      'click .pill-openstack' : 'filterOpenstack',
      'click .pill-chef' : 'filterChef',
      'click .pill-ec2' : 'filterEC2'
    },

    openCreateDialog : function() {
      App.workspaceRegion.currentView.table.show(new CreateView());
    },

    filterCommon : function() {
      this.collection = App.servers_common;
      this.template = table_common;
      this.childView = ServerView;
      this.render();

      $('.pill-common').addClass('active');
      $('.pill-openstack').removeClass('active');
      $('.pill-chef').removeClass('active');
      $('.pill-ec2').removeClass('active');
    },

    filterOpenstack : function() {
      this.collection = App.servers_openstack;
      this.template = table_openstack;
      this.childView = ServerViewOpenstack;
      this.render();

      $('.pill-common').removeClass('active');
      $('.pill-openstack').addClass('active');
      $('.pill-chef').removeClass('active');
      $('.pill-ec2').removeClass('active');
    },

    filterChef : function() {
      this.collection = App.servers_chef;
      this.template = table_chef;
      this.childView = ServerViewChef;
      this.render();

      $('.pill-common').removeClass('active');
      $('.pill-openstack').removeClass('active');
      $('.pill-chef').addClass('active');
      $('.pill-ec2').removeClass('active');
    },

    filterEC2 : function() {
      this.collection = App.servers_ec2;
      this.template = table_ec2;
      this.childView = ServerViewEC2;
      this.render();

      $('.pill-common').removeClass('active');
      $('.pill-openstack').removeClass('active');
      $('.pill-chef').removeClass('active');
      $('.pill-ec2').addClass('active');
    }
  });
});