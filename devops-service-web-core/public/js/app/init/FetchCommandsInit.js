define([

  'App',

  'util/Fetcher',

  'backbone'

], function(App, Fetcher) {

  'use strict';

  return {

    init : function() {
      App.fetcher = Fetcher;

      App.reqres.setHandler('fetch', function(data) {
        return App.fetcher.fetch(data);
      });

      App.reqres.setHandler('refetch', function(data) {
        return App.fetcher.refetch(data);
      });

    }

  };

});
