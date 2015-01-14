define([

  'jquery',

  'hbs!templates/admin_dashboard/image/row',
  'hbs!templates/admin_dashboard/image/table',

  'backbone',
  'marionette',

  'App',
  'models/Image',

  'views/admin_dashboard/image/Create'

], function($, itemTemplate, tableTemplate, Backbone, Marionette, App, Image, ImageCreateView) {
  
  'use strict';

  var ImageView = Backbone.Marionette.ItemView.extend({
    tagName: 'tr',
    template: itemTemplate,

    behaviors: {
      CardShowable: {
        resourceName: 'images'
      }
    }

  });

  return Backbone.Marionette.CompositeView.extend({

    template: tableTemplate,
    childView: ImageView,
    childViewContainer: 'tbody',
    tagName: 'table',
    className:  'table table-responsive table-striped tab-pane',

    behaviors: {
      Refetchable: {}
    },

    events: {
      'click .openCreateDialog' : 'openCreateDialog',
      'click .pill-all' : 'filterAll',
      'click .pill-ec2' : 'filterEC2',
      'click .pill-openstack' : 'filterOpenstack'
    },

    openCreateDialog: function() {
      App.workspaceRegion.currentView.table.show(new ImageCreateView());
    },

    filterAll: function() {
      this.collection = App.images_all;
      this.render();

      $('.pill-all').addClass('active');
      $('.pill-ec2').removeClass('active');
      $('.pill-openstack').removeClass('active');
    },

    filterEC2: function() {
      this.collection = App.images_ec2;
      this.render();

      $('.pill-all').removeClass('active');
      $('.pill-ec2').addClass('active');
      $('.pill-openstack').removeClass('active');
    },

    filterOpenstack: function() {
      this.collection = App.images_openstack;
      this.render();

      $('.pill-all').removeClass('active');
      $('.pill-ec2').removeClass('active');
      $('.pill-openstack').addClass('active');
    }

  });

});
