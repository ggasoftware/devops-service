define([

  'hbs!templates/modals/create_project/input',
  'hbs!templates/modals/create_project/select'

], function (inputTemplate, listTemplate) {

  'use strict';

  return Backbone.Marionette.ItemView.extend({

    template: inputTemplate,
    tagName: 'div',
    className: function () {
      var hidden = this.model.get('hidden')
      if (hidden) {
        return "form-group hidden";
      }
      return "form-group";
    },

    ui: {
      textEntry: '#name-input',
      selectEntry: '.select-entry-provider',
      button: '.dropdown-toggle'
    },

    events: {
      'change @ui.selectEntry': 'selectEntryClickHandler',
      'change @ui.textEntry': 'textEntryChangeHandler'
    },

    modelEvents: {
      'change': 'changeModel'
    },

    initialize: function () {
      var that = this;
      if (this.model.attributes.value === 'null') {
        this.model.set('value', null);
      }
      if (this.model.attributes.type === 'field') {
        this.template = inputTemplate;
      } else {
        this.template = listTemplate;
        var models = this.model.attributes.list.models;
        if (models !== undefined) {
          models = $.map(models, function (item) {
            item.set('selected', (item.get('keyName') === that.model.get('value')));
            return item;
          });
        }
      }
    },

    selectEntryClickHandler: function () {
      var targetvalue = this.$el.find('.select-entry-provider').val();
      if (targetvalue === 'openstack') {
        this.model.switchChildren('openstack');
      } else if (targetvalue === 'ec2') {
        this.model.switchChildren('ec2');
        return;
      } else if (targetvalue === 'static') {
        this.model.switchChildren('static');
        return;
      }

      this.model.switchChildren(targetvalue);
    },

    textEntryChangeHandler: function (ev) {
      this.model.set({
        value: ev.target.value
      });
    },

    onRender: function () {
      var type = this.model.get('type');
      var list = this.model.get('list');
      if((type === 'list' || type === 'disabled-list' ) && (list === undefined || list.length === 0)) {
        this.$el.hide();
      } else {
        this.$el.show();
      }

      if (this.model.get('list') === undefined) {
        return;
      }
      if (this.model.get('type') === 'disabled-list') {
        this.$el.find('.form-control').prop('disabled', true);
      }
      if (this.model.get('type') === 'list' && this.model.get('list').length === 0) {
        this.$el.find('.form-control').prop('disabled', true);
      }
    },

    changeModel: function () {
      var type = this.model.get('type');
      if (type === 'list' || type === 'disabled-list') {
        this.render();
      }
    }

  });
});
