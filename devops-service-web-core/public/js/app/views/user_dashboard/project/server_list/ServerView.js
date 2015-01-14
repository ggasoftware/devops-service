define([

  //libs
  'jquery',
  'backbone',
  'marionette',

  //templates
  'hbs!templates/user_dashboard/project_card/servers',
  'hbs!templates/user_dashboard/project_card/server_card',

  //Application object
  'App'

], function($, Backbone, Marionette, containerTemplate, cardTemplate, App) {
  'use strict';

  return Backbone.Marionette.ItemView.extend({

	tagName : 'div',
	template : cardTemplate,

	ui : {
	  'deploy' : '.deploy-server',
	  'delete' : '.delete-server',
	  'pause' : '.pause-server',
	  'unpause' : '.unpause-server',
	  'reserve' : '.reserve',
	  'runScript' : '.run-script'
	},

	events : {
	  'click @ui.deploy' : 'deployServer',
	  'click @ui.delete' : 'deleteServer',
	  'click @ui.pause' : 'pauseServer',
	  'click @ui.unpause' : 'unpauseServer',
	  'click @ui.reserve' : 'toggleReservedState',
	  'click @ui.runScript' : 'runScript',
	  'click #change' : 'change'
	},

	modelEvents : {
	  'change:deploying' : 'onChangeDeploying',
	  'change:creating' : 'onChangeCreating',
	  'sync' : 'render'
	},

	toggleReservedState : function() {
	  this.model.toggleReservedState();
	},

	runScript : function() {
	  App.vent.trigger('server:modal:runScript', {
		model : this.model
	  });
	},

	onChangeDeploying : function() {
	  if (this.model.get('deploying') === true) {
		this.showLoader();
	  } else {
		this.hideLoader();
	  }
	},

	onChangeCreating : function() {
	  if (this.model.get('creating') === true) {
		this.showLoader();
	  } else {
		this.hideLoader();
	  }
	},

	showLoader : function() {
	  this.$el.find('#deploying-label').show();
	  this.$el.find('#deploying-loader').show();
	},

	hideLoader : function() {
	  this.$el.find('#deploying-label').hide();
	  this.$el.find('#deploying-loader').hide();
	},

	initialize : function() {
	  this.model.attachedView = this;
	  this.on('refetch:servers', this.onRefetchServers);
    this.on('removeModel', this.onRemoveModel);
	},

	onRefetchServers : function() {
	  this.model.collection.fetch();
	},

	deployServer : function() {
	  App.vent.trigger('server:deploy:start', {
      model : this.model
	  });
	},

	deleteServer : function() {
	  App.vent.trigger('server:modal:delete', {
		model : this.model
	  });
	},

	pauseServer : function() {
	  App.vent.trigger('pauseServer', {
		server : this.model
	  });
	},

	unpauseServer : function() {
	  App.vent.trigger('unpauseServer', {
		server : this.model
	  });
	},

	hideIfBingo : function(filterString) {
	  var sub1 = this.model.get('chef_node_name').toLowerCase();
	  var sub2 = this.model.get('modal').deploy_env;
	  if (sub1.indexOf(filterString) !== -1 || sub2.indexOf(filterString) !== -1) {
		$(this.el).show();
	  } else {
		$(this.el).hide();
	  }
	},

	templateHelpers : function() {
	  var model = this.model;
	  if (model.get('modal') === undefined) {
		return null;
	  }
	  var envIdentifier = model.get('modal').deploy_env;
	  var project = model.get('project');
	  var chefEnv = project.getChefEnvForServer(envIdentifier);

	  return {

		chefEnv : function() {
		  return chefEnv;
		},

		reserveLabel : function() {
		  if (model.get('modal').reserved_by) {
			return 'Unreserve';
		  } else {
			return 'Reserve';
		  }
		},

		isStatic : function() {
		  if (model.get('modal').static() === false) {
			return false;
		  } else if (model.get('modal').static() === true) {
			return true;
		  }
		}
	  };
	}
  });

});
