define([

  'jquery',
  'backbone',

  'App',

  'collections/ConsoleMessages'

], function($, Backbone, App, ConsoleMessages) {

  'use strict';
  return Backbone.Model.extend({

    processing: false,

    initialize: function() {
      this.messages = new ConsoleMessages();
      this.set('main', this.attributes.tag == 'Main');
    },

    setProcessing: function(arg) {
      if (!!arg) {
        this.set("processing", true);
      } else {
        this.set("processing", false);
      }
    },

    write: function(string, type) {
      if (string === null) {
        string = '';
			}

      var details = {
        defaults: {css: 'default', header: '>'},
        info: {css: 'info', header: 'INFO'},
        err: {css: 'danger', header: 'ERROR'},
        ok: {css: 'success', header: 'OK'},
        dbug: {css: 'warning', header: 'DEBUG'}
      };

      if (type == 'dbug' && !App.isDebugging)
        return;
      else {
        if (!this.get('active')) {
          this.set('hasUnreadMessages', true);
        }
        this.messages.add({
          data: string.split('\n'),
          type: details[type].css,
          header: details[type].header
        });
      }
    },

    setActive: function() {
      this.set('active', true);
      this.set('hasUnreadMessages', false);
    }

  });

});
