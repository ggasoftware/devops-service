define([

  'hbs!templates/item/datepicker',
  'App'

], function (Template, DSW) {

  'use strict';

  return Backbone.Marionette.ItemView.extend({

    template: Template,

    initialize: function(opts) {
      this.reportsType = opts.collection.type; 
      this.date = opts.collection.date;
    },

    selected: function(date, self) {
      DSW.trigger('controller:reports:show', self.reportsType, date);
    },

    onShow: function() {
      var self = this;
      var datepicker = this.$el.find('#datepicker');
      datepicker.datepicker({
        dateFormat: 'yy-mm-dd',
        onSelect: function(e) {
          self.selected(e, self);
        }
      }); 
      datepicker.datepicker('setDate', this.date);
    }

  });

});
