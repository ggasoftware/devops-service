define([

  'App'

], function (DSW) {

  'use strict';

  DSW.module('Modules.Requests', function (module, app) {

    module.startWithParent = false;


    module.showRequest = function(model) {
      require(['views/item/Request'], function(RequestView) {
        var requestView = new RequestView({model: model}); 
        app.trigger('workspace:show', requestView); 
      });
    };

    module.showProjectRequests = function() {

      require(['views/layouts/RequestsLayout', 'views/composite/Requests'], function(RequestsLayout, RequestsView) {

        app.trigger('bc:route', new Backbone.Collection([

          {
            title: 'requests',
            link: 'requests'
          }

        ]));

        var requestsLayout = new RequestsLayout();

        app.trigger('workspace:show', requestsLayout);


        app.trigger('navbar:requests:setActive');
        var requestsCollection = new Backbone.Collection();

        requestsCollection.url = function() {return app.request('url:get', '/requests');};
          
        var promise = app.request('fetch', requestsCollection);

        promise.done(function(r) {
          var requestsView = new RequestsView({ collection: requestsCollection});
          requestsLayout.requestsWorkspace.show(requestsView);
        });
      });

    };

    module.on('start', function () {
      module.listenTo(app, 'requests:showRequest', module.showRequest);
    });

  });

  return DSW.Modules.Requests;

});
