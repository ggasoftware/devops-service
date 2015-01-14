define([

  'jquery',

  'App'

  ], function($, App) {

  'use strict';

  // helpers

  var sendPostRequest = function(actionUrl, params) {
    var url = App.request('url:get', actionUrl);
    return setCommonCallbacks($.post(url, params));
  };

  var deleteModel = function(model) {
    return setCommonCallbacks(model.destroy({
      wait : true
    }));
  };

  var setCommonCallbacks = function(deferred) {
    deferred.done(function(response) {
      App.execute('console:success', extractMessageFromResponse(response));
    });

    deferred.fail(function(response) {
      App.execute('console:error', extractMessageFromResponse(response));
    });

    return deferred;
  };

  var extractMessageFromResponse = function(response) {
    // response may be parsed JSON (in delete functions) or string in JSON
    // format
    var message;
    if (typeof (response) === 'object') {
      message = response.message || response.responseText || response.statusText;
    } else {
      message = response;
    }

    try {
      return $.parseJSON(message).message;
    } catch (e) {
      return message;
    }
  };

  return {

    // --------------
    // SERVER JOBS
    // --------------

    pauseServer : function(server) {
      var url = '/server/' + server.get('chef_node_name') + '/pause';
      return sendPostRequest(url);
    },

    unpauseServer : function(server) {
      var url = '/server/' + server.get('chef_node_name') + '/unpause';
      return sendPostRequest(url);
    },

    reserveServer : function(server) {

    },

    unreserveServer : function(server) {

    },

    deleteServer : function(server, removeByInstanceID) {
      var sendData = {};
      var serverName = server.get('chef_node_name');
      if(removeByInstanceID) {
        sendData = {key: "instance"};
        serverName = server.get('id');
      }
      var url = App.request('url:get', '/server/' + serverName + '/delete');
      var promise = $.ajax({
        method : 'delete',
        url : url,
        data: sendData
      });
      return promise;
    },

    createProject : function(newProjectData) {
      return sendPostRequest('/project', newProjectData);
    },

    deleteProject : function(project) {
      var url = App.request('url:get', '/models/project/' + project.get('id'));
      var promise = $.ajax({
        method : 'delete',
        url : url
      });
      return promise;
    },

    addUsers : function(usersData, project) {
      var deferred = $.ajax({
        method : 'put',
        url : App.request('url:get', '/project/' + project.get('id') + '/user'),
        data : usersData
      });
      return setCommonCallbacks(deferred);
    },

    removeUser : function(userData, project_id) {
      var deferred = $.ajax({
        method : 'delete',
        url : App.request('url:get', '/project/' + project_id + '/user'),
        data : userData
      });
      return setCommonCallbacks(deferred);
    },

    runScript : function(data) {
      var url = App.reqres.request('url:get', '/script/run/' + data.sendData.scriptId);
      var promise = $.ajax({
        method : 'post',
        url : url,
        data : data.sendData
      });
      return promise;
    },

    // --------------
    // ADMIN DASHBOARD JOBS
    // --------------

    deleteScript : function(script) {
      return deleteModel(script);
    },

    createScript : function(scriptData) {
      var deferred = $.ajax({
        url : '/script',
        type : 'put',
        data : scriptData
      });
      return setCommonCallbacks(deferred);
    },

    createImage : function(imageData) {
      return sendPostRequest('/image', imageData);
    },

    deleteImage : function(image) {
      return deleteModel(image);
    },

    createKey : function(keyData) {
      return sendPostRequest('/key', keyData);
    },

    deleteKey : function(key) {
      return deleteModel(key);
    }

  };
});
