define([

  'App',
  'hbs!templates/composite/breadcrumbs',
  'hbs!templates/item/breadcrumb'

], function (DSW, breadcrumbsTemplate, breadcrumbTemplate) {

  'use strict';

  DSW.module('Modules.Breadcrumbs', function (module, app) {

    module.startWithParent = false;

    var BreadcrumbView = Backbone.Marionette.ItemView.extend({
      template: breadcrumbTemplate,
      tagName: 'li'
    });

    var BreadcrumbsView = Backbone.Marionette.CompositeView.extend({

      template: breadcrumbsTemplate,
      childView: BreadcrumbView,
      childViewContainer: '#breadcrumbs-container',

      initialize: function () {
        console.log('breadcrumbs view init');
      }

    });

    module.on('start', function () {
    });

    module.bcRoute = function (coll) {

      DSW.breadcrumbsRegion.show(new BreadcrumbsView({
        collection: coll
      }));
    };

    module.listenTo(DSW, 'bc:route', module.bcRoute)

  });

  return DSW.Modules.Breadcrumbs;

});
