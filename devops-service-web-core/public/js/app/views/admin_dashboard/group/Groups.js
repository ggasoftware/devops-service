define([

  'jquery',

  'hbs!templates/admin_dashboard/group/row',
  'hbs!templates/admin_dashboard/group/table',

  'backbone',
  'marionette',

  'App'

], function($, itemTemplate, tableTemplate, Backbone, Marionette, App) {

  'use strict';

  var GroupView = Backbone.Marionette.ItemView.extend({
    tagName : 'tr',
    template : itemTemplate
  });

  return Backbone.Marionette.CompositeView.extend({

    template : tableTemplate,
    childView : GroupView,
    childViewContainer : 'tbody',
    tagName : 'table',
    className : 'table table-responsive table-striped table-hover tab-pane',

    behaviors : {
      Refetchable : {}
    },

    events : {
      'click .pill-ec2' : 'filterEC2',
      'click .pill-openstack' : 'filterOpenstack'
    },

    filterEC2 : function() {
      this.collection = App.groups_ec2;
      this.render();

      $('.pill-all').removeClass('active');
      $('.pill-ec2').addClass('active');
      $('.pill-openstack').removeClass('active');
    },

    filterOpenstack : function() {
      this.collection = App.groups_openstack;
      this.render();

      $('.pill-all').removeClass('active');
      $('.pill-ec2').removeClass('active');
      $('.pill-openstack').addClass('active');
    }

  });
});
