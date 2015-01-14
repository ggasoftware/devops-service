define([

  //libs
  'jquery',
  'backbone',
  'marionette',

  //templates
  'hbs!templates/user_dashboard/project_card/servers',
  'hbs!templates/user_dashboard/project_card/server_card',

  //Application object
  'App',
  'views/user_dashboard/project/server_list/ServerView'

], function($, Backbone, Marionette, containerTemplate, cardTemplate, App, ServerView) {

  'use strict';

  return Backbone.Marionette.CompositeView.extend({

    tagName : 'div',
    template : containerTemplate,
    childView : ServerView,
    childViewContainer : '#servers-list',

    events : {
      'keyup #servers-filter' : 'filter'
    },

    filter : function(e) {
      var filterString = e.target.value;
      if (this.children.length !== 0) {
        _.each(this.children._views, function(v) {
          v.hideIfBingo(filterString);
        });
      }
    }
  });
});
