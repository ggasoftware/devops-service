define([

  'jquery',

  'hbs!templates/modals/create_project/deploy_env',

  'backbone',
  'marionette',

  'App',
  'views/modals/dynamic_properties/PropertyView',
  'collections/FormProperties'

], function ($, DeployEnvTemplate, Backbone, Marionette, App, PropertyView, FormProperties) {

  'use strict';

  return Backbone.Marionette.CompositeView.extend({

    childView: PropertyView,
    template: DeployEnvTemplate,
    childViewContainer: '.deploy-env-properties',
    className: 'deploy-env-wrapper',

    events: {
      "click #show-env":"showHideEnv"
    },

    showHideEnv: function (e) {
      var currentText = e.target.innerText;
      if(currentText === 'Collapse') {
        $(e.target).text('Expand')
      } else {
        $(e.target).text('Collapse');
      }
    },

    initialize: function (data) {
      this.deps = this.model.collection.deps;
      this.collection = new FormProperties(null, {
        deployEnv: this.model,
        deps: this.deps
      });
    },

    templateHelpers: function () {
      return {
        viewCid: this.cid
      }
    },

    onShow: function () {
      var collection = this.model.collection;
      var index = collection.indexOf(this.model);
      console.log(this.model.get('identifier'));
      if (collection.length > 1 && this.model.get('identifier')) {
        this.$el.find('.dsw-collapse-panel-' + this.cid).addClass('collapse');
        this.$el.find('#show-env').text('Expand')
      } else {
        this.$el.find('.dsw-collapse-panel-' + this.cid).addClass('in');
        this.$el.find('#show-env').text('Collapse')
      }
    }

  });

});
