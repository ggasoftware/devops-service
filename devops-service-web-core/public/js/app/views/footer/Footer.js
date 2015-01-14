define([

  'App',
  'hbs!templates/footer/footer',

], function (DSW, footerTemplate) {

  'use strict';

  DSW.module('Views.Item.Footer', function (module, app) {

    module.startWithParent = false;

    module.on('start', function () {
      console.log('>>> started Footer');
      app.footerRegion.show(new module.c());
    });

    module.c = Backbone.Marionette.ItemView.extend({
      template: footerTemplate,
      templateHelpers: function () {
        return {
          footerString: app.envMetadata.strings.footer,
          appVersion: app.options.version
        }
      }
    });

  });

  return DSW.Views.Item.Footer;

});
