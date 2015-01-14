define([

  'jquery',
  'hbs!templates/console/tab_container',
  'hbs!templates/console/tab',

  'backbone',
  'marionette',

  'views/console/ConsoleTab',
  'jqueryui'

], function($, containerTemplate, tabTemplate, Backbone, Marionette, TabView) {

  'use strict';
  return Backbone.Marionette.CompositeView.extend({

	childView : TabView,
	tagName : 'ul',
	className : 'nav nav-tabs',
	template : containerTemplate,

	childViewOptions : function() {
	  return {
		parentView : this
	  };
	},

	collectionEvents : {
	  'add' : 'onAdd'
	},

	onShow : function() {
	  this.delegateEvents();
	  this.on('childview:setActiveTab', function(childView, console_model) {
		this.trigger('setActiveTab', console_model);
	  });

	  this.on('childview:closeTab', function(childView, consoleModel) {
		if (consoleModel.get('isCloseable')) {
		  this.collection.remove(consoleModel);
		  this.trigger('setActiveTab', this.collection.at(0));
		}
	  });
	},

	onReset : function() {
	  this.render();
	},

	onAdd : function(addedTab) {
	  this.trigger('setActiveTab', addedTab);
	}

  });
});