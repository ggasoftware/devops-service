define([

  'jquery',
  'backbone',

  'App'

], function ($, Backbone, App) {

  'use strict';

  return Backbone.Model.extend({

    urlRoot: App.request('url:get', '/models/server'),

    deploying: false,
    creating: false,

    url: function () {
      return this.urlRoot + '/' + this.get('chef_node_name');
    },

    toggleReservedState: function () {
      var reserved = this.get('modal').reserved_by;
      if (reserved) {
        App.vent.trigger('server:unreserve', {
          model: this
        });
      } else {
        App.vent.trigger('server:reserve', {
          model: this
        });
      }
    },

    setCreating: function (arg) {
      if (arg === true) {
        this.set('creating', true);
      } else if (arg === false) {
        this.set('creating', false);
      } else {
        App.log('err', 'wrong arguments received at model ' + this.get('id'));
      }
    },

    setDeploying: function (arg) {
      if (arg === true) {
        this.set('deploying', true);
      } else if (arg === false) {
        this.set('deploying', false);
      } else {
        App.log('err', 'wrong arguments received at model ' + this.get('id'));
      }
    },

    parse: function (res) {
      var parsed = {
        chef_node_name: res.chef_node_name,
        id: res.id,

        modal: {
          provider: res.provider,
          chef_node_name: res.chef_node_name,
          remote_user: res.remote_user,
          project: res.project,
          deploy_env: res.deploy_env,
          private_ip: res.private_ip,
          public_ip: res.public_ip,
          created_at: res.created_at,
          created_by: res.created_by,
          reserved_by: res.reserved_by,
          static: res.static,
          key: res.key,
          id: res.id
        }
      };
      return parsed
    }

  });

});
