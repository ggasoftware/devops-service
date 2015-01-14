define([

  'hbs!templates/layouts/requests',

  'App'

], function (layoutTemplate, DSW) {

  'use strict';

  return Backbone.Marionette.LayoutView.extend({

    template: layoutTemplate,

    className: 'container-fluid dsw-rounded-panel',

    regions: {
      requestsWorkspace: '#requests-workspace',
      requestsNav: '#requests-nav'
    },

    initialize: function () {
       
    }

  });

});
