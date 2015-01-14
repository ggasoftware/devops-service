define([

  'jquery',
  'hbs!templates/modals/user_info/modal',

  'backbone'

], function($, modalTemplate, Backbone) {

  'use strict';

  return Backbone.Marionette.CompositeView.extend({

    template : modalTemplate,
    tagName : 'div',
    className : 'modal fade in',

    initialize : function(data) {
      console.log(data.user);
      this.model = data.user;
      this.render();
      this.$el.modal('toggle');
    },

    templateHelpers : function() {
      var privileges, privilegesRows = '';
      privileges = this.model.get('privileges');

      privilegesRows = _.map(privileges, function(plain_value, scope) {
        var value = plain_value === undefined ? '' : plain_value;
        return '<tr><td>' + scope + '</td><td>' + value + '</td></tr>';
      }).join('');

      return {
        privilegesRows : new Handlebars.SafeString(privilegesRows)
      };
    },

  });
});