define([

  'jquery',
  'backbone',
  'marionette',

  'App',
  'backbone.caching-fetcher' // should be last item in required list. Plugin doesn't return any object

  ],function ($, Backbone, Marionette, App) {

    'use strict';

    var redirectToLoginIfNotAuthorized = function(response) {
      console.log(response, '401')
      //if (response.status === 401){
      //  window.location = '/login';
      //}
    };

    var showLoader = function() {
      $('.navbar .loading').removeClass('loaded');
    };

    var hideLoader = function() {
      $('.navbar .loading').addClass('loaded');
    };


    return new window.Backbone.CachingFetcher({
      onFetchStart: showLoader,

      onSuccess: hideLoader,

      onSingleFail: redirectToLoginIfNotAuthorized,

      onFail: function(data) {
        if (!data.fail) {
          App.execute('console:error', 'An error occured during resource fetching');
        }
      }

    });
});
