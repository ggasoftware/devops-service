define([

  'hbs!templates/modals/add_users/modal',
  'hbs!templates/modals/add_users/user',

  'App',
  'util/quickJobHandler'

], function (modalTemplate, itemTemplate, DSW, quickJobHandler) {

  'use strict';

  var childView = Backbone.Marionette.ItemView.extend({

    template: itemTemplate,
    tagName: 'li',
    className: 'list-group-item',

    events: {
      'click #remove-user': 'removeUser'
    },

    removeUser: function () {
      var users = [this.model.get('id')];
      var sendData = {
        'users': users
      };

      this.$el.find('#remove-icon').hide();
      this.$el.find('#loading-indicator').show();

      var projectName = this.model.collection.projectId;
      var that = this;

      var url = DSW.request('url:get', '/project/' + projectName + '/user');
      var promise = $.ajax({
        method: 'delete',
        url: url,
        data: sendData
      });

      promise
        .done(function (r) {
          var message = JSON.parse(r).message;
          $('#info-alert').addClass('alert-success').show().text(message);
          DSW.trigger('project:refetch:' + projectName);
          that.$el.hide();
        }).fail(function (r) {
          var message = JSON.parse(r.responseText).message;
          $('#info-alert').addClass('alert-danger').show().text(message);
          that.$el.find('#loading-indicator').hide();
          that.$el.find('#remove-icon').show();
        });
    }
  });

  var User = Backbone.Model.extend({
    initialize: function (id) {
      this.set('id', id);
    }
  });

  var Users = Backbone.Collection.extend({
    model: User,
    initialize: function (usersArray, options) {
      var projectId = options.projectId;
      var deployEnv = options.deployEnv;
      if (deployEnv !== undefined) {
        // TODO check why data is not defined
        this.url = DSW.request('url:get', '/project/' + projectId + '/users/' + data.deployEnv);
      } else {
        this.url = DSW.request('url:get', '/project/' + projectId + '/users');
      }
      this.projectId = projectId;
      this.deployEnv = deployEnv;
      this.on('usersChanged', this.fetch);
    }
  });

  return Backbone.Marionette.CompositeView.extend({

    template: modalTemplate,
    tagName: 'div',
    className: 'modal fade in',
    childView: childView,
    childViewContainer: '#users-list',

    events: {
      'click #add-users-button': 'addUsers'
    },

    initialize: function (data) {
      var that = this;
      this.model = data.model;
      this.prepareUsersCollection();

      // fetch and render
      this.$el.modal('toggle');
      this.render();

      // react on env users changing:
      // custom event to prevent multiple callback triggers
      this.listenTo(this.collection, 'usersChanged', function () {
        DSW.request('refetch', that.model).done(function () {
          that.prepareUsersCollection();
          that.render();
        });
      });
    },

    prepareUsersCollection: function () {
      this.collection = new Users(this.model.get('users'), {
        projectId: this.model.get('id'),
        deployEnv: this.deployEnv
      });
    },

    onDestroy: function () {
      this.stopListening();
    },

    addUsers: function () {
      var usersData = this.$el.find('form#properties').serializeArray();
      var that = this;

      $('#add-users-loader').show();
      $('#add-users-button').hide();

      var projectName = this.model.get('id');

      var url = DSW.request('url:get', '/project/' + this.model.get('id') + '/user');

      var promise = $.ajax({
        method: 'put',
        url: url,
        data: usersData
      });

      promise
        .done(function (r) {
          var message = JSON.parse(r).message;
          var splitted = message.split(' ');
          var appendix = ['', ''];
          var appendixDanger = ['<strong><span class="text-danger">', '</span></strong>'];
          var splittedChanged = _.map(splitted, function (s) {
            if (s === "invalid") {
              appendix = appendixDanger;
            }
            s = appendix[0] + s + appendix[1];
            return s;
          });
          DSW.trigger('project:refetch:' + projectName);
          var fetchProm = that.model.fetch();
          fetchProm.done(function () {
            that.prepareUsersCollection();
            that.render();
            $('#info-alert').addClass('alert-success').show().html(splittedChanged.join(' '));

          }).fail(function () {
            console.log('no')
          }).always(function () {
            $('#add-users-loader').hide();
            $('#add-users-button').show();
          });
          that.$el.find('input[name=users]').val('');
        })
        .fail(function (r) {
          var message = JSON.parse(r.responseText).message;
          $('#info-alert').addClass('alert-danger').show().text(message);
          $('#add-users-loader').hide();
          $('#add-users-button').show();
        });
    }
  });

});
