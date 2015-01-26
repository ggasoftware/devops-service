require([
  'backbone',
  'App',

  'init/ConsoleEventsInit',
  'init/ServerEventsInit',
  'init/EnvEventsInit',
  'init/ProjectEventsInit',
  'init/ScriptEventsInit',
  'init/UserEventsInit',
  'init/WebsocketInit',
  'init/FetchCommandsInit',
  'init/BehavioursInit',
  'views/modals/alert/Loading',
  'util/UrlHelper',
  'routers/UserRouter',
  'controllers/UserController',
  'envMainModule',
  'views/item/AlertView',
  'views/item/LoadingView',
  'modules/Breadcrumbs',
  'views/modals/NewUserOnboard',
  'jquery',
  'marionette',
  'jqueryui',
  'bootstrap',
  'backbone.validateAll'

], function (Backbone,
             App,
             ConsoleEventsInit,
             ServerEventsInit,
             EnvEventsInit,
             ProjectEventsInit,
             ScriptEventsInit,
             UserEventsInit,
             WebsocketInit,
             FetcherInit,
             BehavioursInit,
             LoadingModal,
             UrlHelper, UserRouter, UserController, EnvMainModule, AlertView, LoadingView, Breadcrumbs, NewUserOnboardModal) {

  'use strict';

  App.reqres.setHandler('alert:loading', function () {
    return new LoadingModal();
  });

  App.reqres.setHandler('get:loadingView', function (opts) {
    return new LoadingView(opts || {});
  });

  App.on('alert:show', function (options) {
    App.alertRegion.show(new AlertView(options));
  });

  EnvMainModule.start();

  Breadcrumbs.start();

  App.settings = {};

  App.reqres.setHandler("pathPrefix", function () {
    return '';
  });
    
  var getAppMetadata = function () {
      
    console.info('Getting app metadata...');

    $.ajax({
      method: 'get',
      url: App.request('pathPrefix') + '/env/metadata'
    }).done(function (r) {

      var parsedResponse = JSON.parse(r);
      App.envMetadata = parsedResponse;

      $.ajax({
        method: 'get',
        url: App.request('pathPrefix') + '/app/options'
      }).done(function (r) {
        App.options = JSON.parse(r);
        App.urlHelper = new UrlHelper();
        App.request('set:serviceHostname', App.options.config.host);
        App.reqres.setHandler('get:accessLevels', function () {
          var aLevels = {
            level3: function () {
              if (App.options.accessLevel > 2) {
                return true;
              }
            },
            level2: function () {
              if (App.options.accessLevel > 1) {
                return true;
              }
            }
          };
          return aLevels;
        });
        App.userRouter = new UserRouter({
          controller: new UserController()
        });
        var envNameModel = Backbone.Model.extend({
          initialize: function (r) {
            this.set('keyName', r);
            this.set('displayName', r);
          }
        });

        var EnvNamesCollection = Backbone.Collection.extend({
          model: envNameModel
        });

        App.options.envNames = new EnvNamesCollection(App.options.envNames);

        startApp();
      });

    });
  };

  var startApp = function () {


    FetcherInit.init();

    App.isDebugging = false;

    App.on('start', function () {

      Handlebars.registerHelper('debug', function () {
        console.log('Handlebars log:');
        console.log(this);
      });

      App.workspaceRegion.on('show', function () {
        App.vent.trigger('routeChanged');
      });

      ConsoleEventsInit.initEvents();
      ServerEventsInit.initEvents();
      EnvEventsInit.initEvents();
      ProjectEventsInit.initEvents();
      ScriptEventsInit.initEvents();
      UserEventsInit.initEvents();
      WebsocketInit.initWebsocket();
    });

    App.start();

  };
    
  getAppMetadata();
    

});
