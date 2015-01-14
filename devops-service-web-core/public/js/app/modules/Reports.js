define([

  'App',
  'collections/ReportRecords'

], function (DSW, ReportsCollection) {

  'use strict';

  DSW.module('Modules.DeployProject', function (module, app) {

    module.startWithParent = false;

    module.showReports = function(opts) {
      app.userRouter.navigate('/reports/' + opts.date);
      var reportsCollection = new ReportsCollection(opts); 
      module.showReportsLayout(reportsCollection);
    };

    module.showReportsLayout = function (reportsCollection) {
      require([
        'views/layouts/ReportsLayout',
        'views/user_dashboard/Reports'], function (ReportsLayout, ReportsView) {

        var type = reportsCollection.type;
        var date = reportsCollection.date;

        app.trigger('navbar:reports:setActive');

        app.trigger('bc:route', new Backbone.Collection([

          {
            title: 'reports',
            link: 'reports'
          },

          {
            title: date,
            link: 'reports/' + date
          }

        ]));

        var layoutHeader = (function() {
          return date;
        })();

        var reportsLayout = new ReportsLayout({header: layoutHeader});

        var loadingView = app.request('get:loadingView', {
          title: "Please wait",
          message: "Loading reports"
        });

        app.trigger('workspace:show', loadingView);

        DSW.request('fetch', reportsCollection).done(function () {
          app.trigger('workspace:show', reportsLayout);
          reportsLayout.reportsWorkspace.show(new ReportsView({
            collection: reportsCollection
          }));
        });
      });
      module.showReportsDatepicker({collection: reportsCollection});
    };

    module.showReportsDatepicker = function (opts) {
      require(['views/item/Datepicker'], function(DatepickerView) {
        var datepickerView = new DatepickerView(opts); 
        app.trigger('workspace:nav:show', datepickerView);
      });
    }

  });

  return DSW.Modules.DeployProject;

});
