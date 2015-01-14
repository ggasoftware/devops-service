define([

    'App',
    'backbone',
    'marionette',

    'util/Redirector',

    // layout
    'views/admin_dashboard/Layout'

], function (App, Backbone, Marionette, Redirector, AdminLayout) {

  	'use strict';
    // private
    var showAdminLayout = function() {
      var layout = new AdminLayout();
      App.workspaceRegion.show(layout);
      return layout;
    };

    var redirectToIndex = function(controllerName) {
      Redirector.redirect_to('admin/' + controllerName);
    };

    // public

    return Backbone.Marionette.Controller.extend({
      // Functions 'prepareLayoutAndShowResource(s)' are executed only when user came into app
      // with certain URL fragment (e.g. #admin/keys or #/admin/keys/asd)

      initialize: function() {
        var that = this;
        App.vent.on('admin:' + that.name + ':index', function() {
          that.showResources();
          App.navigate('admin/' + that.name);
        });

        App.vent.on('admin:' + that.name + ':show', function(model) {
          that.showResource(model);
          App.navigate('admin/' + that.name + '/' + model.id);
        });
      },


      // show admin layout, fetch required collection and then show collection
      prepareLayoutAndShowResources: function () {
        showAdminLayout();
        this.showResources();
      },

      // show admin layout, fetch required collection, select required model and then it
      // if model is absent, redirect to index
      prepareLayoutAndShowResource: function(id) {
        var layout = showAdminLayout();
        layout.setActivePage(this.name);

        var that = this;
        App.request('fetch', this.requredCollections()).done(function() {

          // somewhy #get doesn't work after refetch
          var model = that.mainCollection().find(function(item){
							return item.id === id;
					});

          if (model) {
            that.showResource(model);
          } else {
            redirectToIndex(that.name);
          }
        });
      },

      showResources: function() {
        App.workspaceRegion.currentView.setActivePage(this.name);
        var that = this;

        App.request('fetch', this.requredCollections()).done(function() {
          var indexView = new that.indexView({collection: that.mainCollection()});
          App.workspaceRegion.currentView.table.show(indexView);

          indexView.on('reloadCollection', function() {
            App.request('refetch', that.requredCollections());
          });
        });
      },

      showResource: function(model) {
        // currentView should be AdminLayout at this moment
        App.workspaceRegion.currentView.table.show(new this.showView({model: model}));
      }

    });

});
