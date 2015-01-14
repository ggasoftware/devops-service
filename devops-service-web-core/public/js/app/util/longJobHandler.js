define([

  'jquery',

  'App'

  ], function($, App) {

  'use strict';

  // var constructConsoleTabName = function(model, operation_type) {
  // return operation_type + ' #' + model.cid.replace('c', '');
  // };
  //
  // var sendRequestForLongJob = function(actionUrl, params, waiter ) {
  // $.post(actionUrl, params);
  // };

  return {

    startDeployServer : function(data) {
      var url = App.request('url:get', '/server/deploy');
      var promise = $.post(url, {
        names : data.names
      });
      promise.done(function(data) {
        App.vent.trigger('server:deploy:started', data);
      });
    },

    createServerDialog : function(data) {
      var url = App.request('url:get', +'/server/create');
      var promise = $.post(url, data);
      promise.done(function(data) {
        App.vent.trigger('server:create:started', data);
      });
    },

    // TODO ??
    createServer : function() {
      // tabName = constructConsoleTabName(data.context.model, 'CreateServer');
      // requestParams = {
      // server: data.data,
      // extra: {
      // stopEventName: 'stopCreateServer',
      // tabName: tabName
      // }
      // };

      // sendRequestForLongJob(App.pathPrefix + '/server', requestParams,
      // data.context.model);
    },

    startDeployProject : function() {
    },

    startDeployEnv : function(data) {
      App.vent.trigger('project:environment:deploy:started', data);
      var url = App.request('url:get', '/project/' + data.model.get('project').get('id') + '/deploy');
      var sendData = {
        deploy_env : data.model.get('identifier')
      };
      var ajax = $.ajax({
        method : 'post',
        url : url,
        data : sendData
      });

      var promise = $.when(ajax).done(function(data) {
        App.execute('console:success', data);
      });
      promise.fail(function(data) {
        App.execute('console:error', 'failed deploying environment! Server response: ' + data.status + ' ' + '(' + data.statusText + ')');
      });
    }

  };
});