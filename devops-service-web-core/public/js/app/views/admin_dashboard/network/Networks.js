define([

  'jquery',

  'hbs!templates/admin_dashboard/network/row',
  'hbs!templates/admin_dashboard/network/table',

  'backbone',
  'marionette',

  'App',
  'models/Network'

], function($, rowTemplate, tableTemplate, Backbone, Marionette, App, Network) {
  
  'use strict';

  var NetworkView = Backbone.Marionette.ItemView.extend({

    tagName : 'tr',
    template : rowTemplate

  });

  return Backbone.Marionette.CompositeView.extend({

    template : tableTemplate,
    childView : NetworkView,
    childViewContainer : 'tbody',
    tagName : 'table',
    className : 'table table-responsive table-striped table-hover tab-pane',

    behaviors : {
      Refetchable : {}
    },

    events : {
      'click .pill-openstack' : 'filterOpenstack',
      'click .pill-ec2' : 'filterEC2'
    },

    filterOpenstack : function() {
      this.collection = App.networks_openstack;
      this.render();

      $('.pill-openstack').addClass('active');
      $('.pill-ec2').removeClass('active');
    },

    filterEC2 : function() {
      this.collection = App.networks_ec2;
      this.render();

      $('.pill-openstack').removeClass('active');
      $('.pill-ec2').addClass('active');
    }

  });
});