// Jasmine Unit Testing Suite
//
// Testing App-init, views, models and collections

define([

  'views/admin_dashboard/Layout',

  'views/admin_dashboard/image/Images',
    'views/admin_dashboard/image/Card',
    'views/admin_dashboard/image/Create',

  'views/admin_dashboard/project/Projects',
    'views/admin_dashboard/project/Card',
    'views/admin_dashboard/project/Create',


  'views/admin_dashboard/server/Servers',
    'views/admin_dashboard/server/Card',
    'views/admin_dashboard/server/Create',

  'views/admin_dashboard/group/Groups',
  'views/admin_dashboard/user/Users',
  'views/admin_dashboard/key/Keys',
  'views/admin_dashboard/script/Scripts',
  'views/admin_dashboard/network/Networks',

], function(

    AdminLayout,

    ImagesView,
      ImagesCardView,
      ImagesCreateView,

    ProjectsView,
      ProjectCardView,
      ProjectCreateView,

    ServersView,
      ServersCardView,
      ServersCreateView,

    GroupsView,
    UsersView,
    KeysView,
    ScriptsView,
    NetworksView) {

    describe("VIEWS", function() {
        describe("Admin dashboard", function() {

            describe("Admin layout", function() {

              it("init", function() {
                var adminLayout = new AdminLayout();
              });

            });

            describe("Images", function() {

                it("Table view", function() {
                    var imagesView = new ImagesView();
                });

                it("Card view", function() {
                    var imageCardView = new ImageCardView();
                });

                xit("Create view", function() {
                    var imageCreateView = new ImageCreateView();
                });

            });

            describe("Projects", function() {

                it("Table view", function() {
                    var projectsView = new ProjectsView();
                });

                it("Card view", function() {
                    var projectCardView = new ProjectCardView();
                });

                it("Create view", function() {
                    var projectCreateView = new ProjectCreateView();
                });

            });


            describe("Servers", function() {

                it("Table view", function() {
                    var serversView = new ServersView();
                });

                it("Card view", function() {
                    var serversCardView = new ServersCardView();
                });

                it("Create view", function() {
                    var serversCreateView = new ServersCreateView();
                });

            });

            describe("Groups", function() {

                it("Table view", function() {
                    var groupsView = new GroupsView();
                });

            });

            describe("Users", function() {

                it("Table view", function() {
                    var usersView = new UsersView();
                });

            });

            describe("Keys", function() {

                it("Table view", function() {
                    var keysView = new KeysView();
                });

            });

            describe("Scripts", function() {

                it("Table view", function() {
                    var scriptsView = new ScriptsView();
                });

            });

            describe("Networks", function() {

                it("Table view", function() {
                    var networksView = new NetworksView();
                });

            });

        });
    });

});
