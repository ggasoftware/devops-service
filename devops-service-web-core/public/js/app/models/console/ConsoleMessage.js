define([

  'jquery',
  'backbone',

  'App'

], function($, Backbone) {

  'use strict';
  return Backbone.Model.extend({
	defaults : {
	  type : 'info',
	  header : 'INFO'
	}
  });

});
