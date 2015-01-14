define([

  'backbone',
  'marionette'

],  function(Backbone) {

  // helpers start

  'use strict';
  var createAdminRouter = function(resourceName, skipShowRoute) {
    var routes = {};
    routes['admin/' + resourceName] = 'prepareLayoutAndShowResources';
    if (skipShowRoute !== true) {
      routes['admin/' + resourceName + '/:id'] = 'prepareLayoutAndShowResource';
    }

    return Backbone.Marionette.AppRouter.extend({
      appRoutes: routes
    });
  };

  var adminOverviewRouter = function() {
    return Backbone.Marionette.AppRouter.extend({
      appRoutes: {
        'admin' : 'prepareLayoutAndShowResources'
      }
    });
  };

  // helpers end

  // manually create all routers to leave ability
  // to change some routers lately
  return {
    overview: adminOverviewRouter(),
    images: createAdminRouter('images'),
    projects: createAdminRouter('projects'),
    servers: createAdminRouter('servers'),
    flavors: createAdminRouter('flavors', true),
    groups: createAdminRouter('groups', true),
    users: createAdminRouter('users', true),
    networks: createAdminRouter('networks', true),
    keys: createAdminRouter('keys'),
    scripts: createAdminRouter('scripts')
  };
});
