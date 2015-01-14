define([

  //libs
  'backbone',
//  'marionette',
//  'underscore',

//  'App',
//
//  'views/modals/CreateServer',
//  'views/modals/alert/DeleteServer',
//  'views/modals/AddUsers',
//  'views/modals/AddEnvironments',
//  'util/longJobHandler'

//  ],function ($, Backbone, Marionette, _, App, CreateServerModal, DeleteServerAlert, AddUsersModal, AddEnvironmentsModal, longJobHandler) {

  ],function (Backbone) {
  
    'use strict';

    return Backbone.Marionette.Object.extend({
    });
    
    //TODO deprecated?
//      manageUsers: function(data) {
//        new AddUsersModal({
//          project: data.project,
//          deploy_env: data.env.get('identifier'),
//          users: data.env.get('users')
//        });
//      },
//
//      deployEnv: function(data) {
//        longJobHandler.startDeployEnv({
//          context: data.context
//        });
//      },
//
//      viewServers: function(data) {
//        //TODO make filter for servers list (servers for selected deploy env)
//        App.execute('console:debug', 'STUB: showing servers for env ' + data.env.get('identifier'));
//      }

});
