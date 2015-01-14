define([

  'jquery',
  'hbs!templates/console/message',

  'backbone',
  'marionette',

  'models/console/ConsoleMessage',
  'jqueryui'

], function($, itemTemplate, Backbone, Marionette, ConsoleMessage) {

  'use strict';
  var MessageView = Backbone.Marionette.ItemView.extend({
	template : itemTemplate,
	model : ConsoleMessage
  });

  return Backbone.Marionette.CollectionView.extend({

	childView : MessageView,

	collectionEvents : {
	  'add' : 'onAdd',
	  'reset' : 'onReset'
	},

	setActiveConsole : function(consoleModel) {
	  this.collection = consoleModel.messages;
	  this.delegateEvents();
	  this.render();
	  this.scrollDownFast();
	},

	onShow : function() {
	  this.scrollDownFast();
	},

	onReset : function() {
	  this.render();
	},

	onAdd : function() {
	  this.render();
	  // scroll down
	  $('#messages').animate({
		scrollTop : $('#messages')[0].scrollHeight
	  }, 300);
	},

	scrollDownFast : function() {
	  $('#messages').scrollTop($('#messages')[0].scrollHeight);
	}

  });
});