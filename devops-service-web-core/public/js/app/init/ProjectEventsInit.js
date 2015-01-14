define([

  'App',
  'events/Project'

], function(App, ProjectEventHandler) {
  
  'use strict';

  return {

    initEvents : function() {

      new ProjectEventHandler();

    }
  };

});
