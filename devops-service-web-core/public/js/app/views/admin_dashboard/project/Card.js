define([

  'hbs!templates/admin_dashboard/project/card',

  'backbone',
  'marionette',

  'App',
  'views/modals/alert/DeleteProject',
  'models/Project',
  'util/Redirector'

], function(cardTemplate, Backbone, Marionette, App, DeleteProjectAlert, Project, Redirector) {

  'use strict';
  return Backbone.Marionette.ItemView.extend({

    tagName : 'div',
    template : cardTemplate,

    behaviors : {
      HasBackLink : {
        resourceName : 'projects'
      }
    },

    events : {
      'click .delete-button' : 'deleteProject',
      'click .createServer' : 'createServer'
    },

    onShow : function() {
      var project = this.model;
      var that = this;

      App.request('fetch', {
        toFetch : project,
        success : function() {
          var deploy_envs = _.map(project.get('deploy_envs').models, function(env) {
            return env.attributes;
          });

          that.templateHelpers = {
            deploy_envs_helper : deploy_envs
          };

          that.render();
        }
      });

      this.bindOnDestroyCallbacks();
    },

    bindOnDestroyCallbacks : function() {
      this.model.on('destroy', function() {
        App.request('refetch', App.projects);
        Redirector.redirect_to('admin/projects');
      });
    },

    createServer : function(ev) {
      var id = this.model.id;
      var deploy_env = ev.target.value;

      if (confirm('Create server for project ' + id + ' and environment ' + deploy_env + '?')) {
        alert('Sorry, this feature is not implemented yet for admin dashboard.');
        /* App.tabContentRegion.show(new WebSocketView({ */
        // action: '/server',
        // data: {
        // project_id: id,
        // env: deploy_env
        // },
        /* })); */
      } else {
        alert('Server creation aborted');
      }
    },

    deleteProject : function() {
      new DeleteProjectAlert({
        model : this.model
      });
    }
  });
});