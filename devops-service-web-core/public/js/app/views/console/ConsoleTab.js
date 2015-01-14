define([

  'jquery',
  'backbone',
  'marionette',

  'hbs!templates/console/tab',

  'models/console/Console',
  'jqueryui'

], function($, Backbone, Marionette, tabTemplate, Console) {

  'use strict';
  return Backbone.Marionette.ItemView.extend({

	template : tabTemplate,
	model : Console,
	tagName : 'li',

	events : {
	  'click .close-tab' : 'closeTab',
	  'click' : 'setActiveTab'
	},

	modelEvents : {
	  'change:active' : 'render',
	  'change:hasUnreadMessages' : 'render'
	},

	initialize : function(options) {
	  this.parentView = options.parentView;
	  this.setActiveTab();
	},

	setActiveTab : function(e) {
	  if (!!e) {
		e.preventDefault();
	  }
	  this.parentView.$el.children('li').removeClass('active');
	  this.$el.addClass('active');
	  this.trigger('setActiveTab', this.model);
	},

	closeTab : function(e) {
	  e.stopPropagation();
	  this.trigger('closeTab', this.model);
	},

	onRender : function() {
	  if (!this.model.get('isCloseable')) {
		this.$el.find('.close-tab').hide();
	  }
	  if (this.model.get('active')) {
		this.$el.addClass('active');
	  }
	}

  });

});
