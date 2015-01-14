define([

  'jquery',

  'hbs!templates/admin_dashboard/flavor/row_openstack',
  'hbs!templates/admin_dashboard/flavor/row_ec2',

  'hbs!templates/admin_dashboard/flavor/table_openstack',
  'hbs!templates/admin_dashboard/flavor/table_ec2',

  'backbone',
  'marionette',

  'App'

], function($, itemTemplateOpenstack, itemTemplateEC2, tableTemplateOpenstack, tableTemplateEC2, Backbone, Marionette, App) {

  'use strict';

  var FlavorViewOpenstack = Backbone.Marionette.ItemView.extend({
    tagName : 'tr',
    template : itemTemplateOpenstack
  });

  var FlavorViewEC2 = Backbone.Marionette.ItemView.extend({
    tagName : 'tr',
    template : itemTemplateEC2
  });

  return Backbone.Marionette.CompositeView.extend({

    template : tableTemplateOpenstack,
    childView : FlavorViewOpenstack,
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
      this.collection = App.flavors_ec2;
      this.childView = FlavorViewEC2;
      this.template = tableTemplateEC2;
      this.render();

      $('.pill-all').removeClass('active');
      $('.pill-ec2').addClass('active');
      $('.pill-openstack').removeClass('active');
    },

    filterOpenstack : function() {
      this.collection = App.flavors_openstack;
      this.childView = FlavorViewOpenstack;
      this.template = tableTemplateOpenstack;
      this.render();

      $('.pill-all').removeClass('active');
      $('.pill-ec2').removeClass('active');
      $('.pill-openstack').addClass('active');
    }

  });

});
