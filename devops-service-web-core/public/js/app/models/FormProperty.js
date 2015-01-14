define([

  'jquery',
  'underscore',
  'backbone',
  'App'

], function ($, _, Backbone, App) {

  'use strict';

  return Backbone.Model.extend({

    defaults: {
      value: 'null',
      children: 'null',
      list: [],
      openstackList: []
    },

    corrected_names: {
      'openstack': 'openstackList',
      'ec2': 'ec2List',
      'static': 'staticList'
    },

    switchChildren: function (arg) {
      var that = this;
      _.each(this.get('children'), function (child_id) {
        console.log(that.collection);
        that.collection.get(child_id).switchTo(that.corrected_names[arg]);
      });
    },

    switchTo: function (provider) {
      this.set({
        list: this.get(provider)
      });
    }

  });

});
