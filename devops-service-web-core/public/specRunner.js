(function() {
  'use strict';
  // Configure RequireJS to shim Jasmine
  require.config({
    baseUrl: './js/app',
    paths: {
       "jasmine": "../libs/jasmine/jasmine",
       "jasmine-html": "../libs/jasmine/jasmine-html",
       "json2":"../libs/json2",
       "boot": '../libs/jasmine/boot',
       "jquery":"//cdnjs.cloudflare.com/ajax/libs/jquery/2.0.3/jquery.min",
       "underscore":"../libs/lodash",
       "backbone":"../libs/backbone",
       "marionette":"../libs/backbone.marionette",
       "handlebars":"../libs/handlebars",
       "hbs":"../libs/hbs",
       "i18nprecompile":"../libs/i18nprecompile",
 
    },

    shim: {
      'underscore': {
        exports: '_'
      },
        "backbone":{
            // Depends on underscore/lodash and jQuery
            "deps":["underscore", "jquery"],
            // Exports the global window.Backbone object
            "exports":"Backbone"
        },
        "marionette":{
            "deps":["underscore", "backbone", "jquery"],
            "exports":"Marionette"
        },
        "handlebars":{
            "exports":"Handlebars"
        },



      'jasmine': {
        exports: 'jasmine'
      },
      'jasmine-html': {
        deps: ['jasmine'],
        exports: 'jasmine'
      },
      'boot': {
        deps: ['jasmine', 'jasmine-html'],
        exports: 'jasmine'
      }
    },
    hbs: {
        templateExtension: "html",
        helperDirectory: "templates/helpers/",
        i18nDirectory: "templates/i18n/",

        compileOptions: {}        // options object which is passed to Handlebars compiler
    }

  });

  // Define all of your specs here. These are RequireJS modules.
  var specs = [
    '../test/specs/AddEnvironment',
  ];

  // Load Jasmine - This will still create all of the normal Jasmine browser globals unless `boot.js` is re-written to use the
  // AMD or UMD specs. `boot.js` will do a bunch of configuration and attach it's initializers to `window.onload()`. Because
  // we are using RequireJS `window.onload()` has already been triggered so we have to manually call it again. This will
  // initialize the HTML Reporter and execute the environment.
  require(['jquery', 'underscore', 'backbone', 'marionette','boot'], function () {

    // Load the specs
    require( specs, function () {

      // Initialize the HTML Reporter and execute the environment (setup by `boot.js`)
      window.onload();
    });
  });
})();
