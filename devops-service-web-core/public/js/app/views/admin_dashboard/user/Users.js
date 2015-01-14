define([

  'jquery',

  'hbs!templates/admin_dashboard/user/row',
  'hbs!templates/admin_dashboard/user/table',

  'backbone'

], function($, itemTemplate, tableTemplate, Backbone) {

  'use strict';

  var UserView = Backbone.Marionette.ItemView.extend({
    tagName : 'tr',
    template : itemTemplate
  });

  return Backbone.Marionette.CompositeView.extend({

    template : tableTemplate,
    childView : UserView,
    childViewContainer : 'tbody',
    tagName : 'table',
    className : 'table table-responsive table-striped table-hover tab-pane',

    behaviors : {
      Refetchable : {}
    }

  });

});