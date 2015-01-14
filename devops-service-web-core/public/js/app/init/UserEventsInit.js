define([

  'App',
  'events/User'

], function(App, UserEventHandler) {

  'use strict';

  return {

    initEvents : function() {
      new UserEventHandler();
    }

  };

});
