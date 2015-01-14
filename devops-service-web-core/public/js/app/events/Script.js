define([

  //libs
  'jquery',
  'backbone',
  'marionette',
  'underscore',

  //App
  'App',

  'views/modals/CreateServer',
  'views/modals/alert/DeleteServer',
  'views/modals/RunScriptModal',
  'views/modals/AddScriptModal',
  'views/modals/alert/DeleteScript',

  'views/admin_dashboard/script/Scripts',
  'util/Redirector'

], function($, Backbone, Marionette, _, App, CreateServerModal, DeleteServerAlert, RunScriptModal, AddScriptModal, DeleteScriptModal, ScriptsView, Redirector) {

  'use strict';

  return {

    showAddScriptModal : function() {
      new AddScriptModal();
    },

    showDeleteScriptModal : function(data) {
      new DeleteScriptModal({
        model : data.script
      });
    },

    showScriptsList : function() {
      Redirector.redirect_to('admin/scripts');
    }
  };
});