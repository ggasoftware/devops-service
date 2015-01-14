define([

  'jquery',
  'hbs!templates/modals/run_script/modal',
  'hbs!templates/modals/run_script/item',

  'backbone',
  'marionette',

  'App'

], function($, modalTemplate, itemTemplate, Backbone, Marionette, App) {

  'use strict';

  var ScriptView = Backbone.Marionette.ItemView.extend({

    tagName : 'li',
    className : 'list-group-item cursor-pointer active-hover',
    template : itemTemplate,

    events : {
      'click' : 'clickHandler'
    },

    initialize : function() {
      this.initEvents();
    },

    initEvents : function() {
      this.on('selectedScript', function() {
        this.$el.siblings().removeClass('active');
        this.$el.addClass('active');
      });
    },

    clickHandler : function() {
      this.trigger('selectedScript', {
        model : this.model
      });
    }
  });

  return Backbone.Marionette.CompositeView.extend({

    template : modalTemplate,
    tagName : 'div',
    className : 'modal fade in',
    childView : ScriptView,
    childViewContainer : '#script-list',
    runOptions : {},

    events : {
      'click #run-script' : 'runScript'
    },

    initialize : function(data) {
      this.collection = App.scripts;
      console.log(App.scripts);
      this.runOptions.serverId = data.model.get('chef_node_name');
      this.initEvents();
      this.render();
      this.$el.modal('toggle');
    },

    initEvents : function() {
      this.on('childview:selectedScript', function(itemData) {
        this.scriptToRun = itemData.model.get('id');
        // this.$el.find('.list-group-item').removeClass('active');
        // this.hideModal();
      });
    },

    hideModal : function() {
      this.$el.modal('hide');
    },

    getScriptParams : function() {
      var paramsString = this.$el.find('#script-params').val();
      return paramsString.split(',');
    },

    runScript : function() {
      if (this.scriptToRun === undefined || this.scriptToRun === '') {
        alert('Error running script');
        return null;
      }
      var scriptParams = this.getScriptParams();
      var eventData = {
        sendData : {
          scriptId : this.scriptToRun,
          nodes : [ this.runOptions.serverId ],
          params : scriptParams
        },
        client : this
      };
      App.vent.trigger('server:script:run', eventData);
      this.$el.modal('hide');
    }

  });
});