define([

  'jquery',

  'App'

  ], function($, App) {

  'use strict';

  var constructConsoleTabName = function(model, operation_type) {
    return operation_type + ' #' + model.cid.replace('c', '');
  };

  var sendRequestForLongJob = function(actionUrl, params, waiter) {
    // we need to access deployed server when operation ends,
    // that's why store it in App.websocketWaiters
    App.websocketWaiters[tabName] = waiter;

    // Send message to console tab immediatly.
    App.execute('console:info', 'Operation started', params.extra.tabName);

    // Send request to Sinatra to init Worker
    $.post(actionUrl, params);
  };

  return {

    startDeployServer : function(data) {
      // Tell everyone about this operation
      App.vent.trigger('startDeployServer', {
        context : data.context
      });

      // prepare params
      var tabName = constructConsoleTabName(data.context.model, 'DeployServer');

      var requestParams = {
        names : data.names,
        extra : {
          tabName : tabName,
          stopEventName : 'stopDeployServer' // do not automate event name creating to simplify search within project
        }
      };

      // send request
      sendRequestForLongJob('/deploy', requestParams, data.context.model);
    },

    createServer : function(data) {
      var tabName = constructConsoleTabName(data.context.model, 'CreateServer');

      var requestParams = {
        server : data.data,
        extra : {
          stopEventName : 'stopCreateServer',
          tabName : tabName
        }
      };

      sendRequestForLongJob('/server', requestParams, data.context.model);
    },

    startDeployProject : function(data) {
      App.vent.trigger('startDeployProject');

      var tabName = constructConsoleTabName(data.context.model, 'DeployProject');
      var actionUrl = '/project/' + data.context.model.get('id') + '/deploy';

      var requestParams = {
        data : {},
        extra : {
          tabName : tabName,
          stopEventName : 'stopDeployProject'
        }
      };

      sendRequestForLongJob(actionUrl, requestParams, data.context.model);
    },

    startDeployEnv : function(data) {
      App.vent.trigger('startDeployProject', {
        context : data.context
      });

      var env_id = data.context.model.get('identifier');
      var project_id = data.context.model.get('project_id');

      var tabName = constructConsoleTabName(data.context.model, 'DeployEnv');
      var actionUrl = '/project/' + project_id + '/deploy';

      var requestParams = {
        data : {
          deploy_env : env_id
        },
        extra : {
          tabName : tabName,
          stopEventName : 'stopDeployProject'
        }
      };

      sendRequestForLongJob(actionUrl, requestParams, data.context.model);
    }

  };
});