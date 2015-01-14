define([

  'handlebars'

], function(Handlebars) {
  'use strict';

  function yeller(context) {
    // Assume it's a string for simplicity.
    return context + '!!!!!!!!';
  }

  Handlebars.registerHelper('yeller', yeller);
  return yeller;

});