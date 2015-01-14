define([

  'jquery',
  'hbs!templates/admin_dashboard/image/create',

  'backbone',
  'marionette',

  'App',
  'util/quickJobHandler'

], function($, createTemplate, Backbone, Marionette, App, quickJobHandler) {

  'use strict';
  return Backbone.Marionette.CompositeView.extend({

    tagName: 'div',
    template: createTemplate,

    events: {
      'click .createImage' : 'createImage',
      'click .selectProvider' : 'clickHandlerProviders',
      'click .selectImage' : 'clickHandlerImages'
    },

    clickHandlerProviders: function(ev) {
      var value = ev.target.text;
      this.currentProvider = value;

      $('.dropdownProviders').text(value);

      //TODO replace model.attributes with model.get and checkit
      if (value === 'ec2') {
        this.model.attributes.images = App.images_ec2_blank.models;
      } else if (value === 'openstack') {
        this.model.attributes.images = App.images_openstack_blank.models;
      }
      if (value === 'ec2' || value === 'openstack') {
        this.currentImage = this.model.attributes.images[0].attributes.image_id;
        this.render();
      }
    },

    clickHandlerImages: function(ev) {
      this.currentImage = ev.target.text;
      $('.dropdownImages').text(ev.target.text);
    },

    onRender: function() {
      if (this.currentProvider) {
        $('.dropdownProviders').text(this.currentProvider);
      }
      if (this.currentImage) {
        $('.dropdownImages').text(this.currentImage);
      }
    },

    //TODO replace model.attributes with model.get and checkit
    initialize: function() {
      this.model = new Backbone.Model();
      this.model.attributes.providers = App.providers.models;
      this.model.attributes.images = App.images_openstack_blank.models;

      var that = this;
      App.request('fetch', {
        toFetch: [App.providers, App.images_openstack_blank, App.images_ec2_blank],
        success: function() {
          that.render();
        }
      });
    },

    createImage: function() {
      var imageData = $('#create-image-form').serializeArray();
      imageData.push({name: 'id', value: this.currentImage});
      imageData.push({name: 'provider', value: this.currentProvider});

      quickJobHandler.createImage(imageData);
    }
  });

});