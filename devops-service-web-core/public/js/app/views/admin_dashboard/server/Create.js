define([

  'jquery',

  'hbs!templates/admin_dashboard/server/create',

  'backbone'

], function($, createTemplate, Backbone) {

  'use strict';
  return Backbone.Marionette.CompositeView.extend({

	tagName : 'div',
	template : createTemplate,

	events : {
	  'click .createServer' : 'createServer'
	},

	createServer : function() {
	  //var formParams = $('#create-server-form').serializeArray();
	  alert('Sorry, this feature is not implemented yet for admin dashboard.');
	}
  });
});
