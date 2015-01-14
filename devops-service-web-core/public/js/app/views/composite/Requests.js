define([

  'jquery',
  'backbone',
  'marionette',

  'hbs!templates/composite/requests/container',
  'hbs!templates/composite/requests/item',
  'hbs!templates/composite/requests/no-requests',

  'App'

], function ($, Backbone, Marionette, containerTemplate, itemTemplate, noReportsTemplate, App) {

  'use strict';

  var EmptyView = Backbone.Marionette.ItemView.extend({

    template: noReportsTemplate,
    tagName: 'tr'
  
  });

  var RecordView = Backbone.Marionette.ItemView.extend({

    template: itemTemplate,
    tagName: 'tr',
    className: 'cpointer',

    events: {
      "click": "clickHandler"
    },

    clickHandler: function() {
      App.trigger('requests:showRequest', this.model);
    }

  });

  return Backbone.Marionette.CompositeView.extend({

    template: containerTemplate,
    childView: RecordView,
    childViewContainer: '#requests-list',
    emptyView: EmptyView,

  });
});
