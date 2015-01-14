// Jasmine Unit Testing Suite
// Testing collections  

define([

  'collections/Providers',
  'collections/Images',
  'collections/Projects',
  'collections/Servers',
  'collections/Flavors',
  'collections/Groups',
  'collections/Users',
  'collections/Keys',
  'collections/Networks',
  'collections/Tabs',
  'collections/Scripts',

], function(
  Providers,
  Images,
  Projects,
  Servers,
  Flavors,
  Groups,
  Users,
  Keys,
  Networks,
  Tabs,
  Scripts) {

  describe("COLLECTIONS", function() {

    describe("Initialization", function() {

    var describeInit = function(name, coll, run) {
      describe(name, function() {
          beforeEach(function() {
              this.collection = new coll();
              this.collection.fetch({
                success: function(coll) {
                  console.log(coll);
                }

              });
          });

        if (run === true) {
          it("should contain the correct number of models", function() {
              expect(this.collection.length).toEqual(0);
          });
        } else {
          xit("should contain the correct number of models", function() {
              expect(this.collection.length).toEqual(0);
          });
          }
      });
    };

      describeInit("Providers", Providers, true);
      describeInit("Images", Images, true);
      describeInit("Projects", Projects, true);
      describeInit("Servers", Servers, true);
      describeInit("Flavors", Flavors, true);
      describeInit("Groups", Groups, true);
      describeInit("Users", Users, true);
      describeInit("Keys", Keys, true);
      describeInit("Scripts", Scripts, true);
      describeInit("Networks", Networks, true);

    });

      describe("Fetch models from server", function() {

        var describeFetch = function(name, coll, run) {
          describe(name, function() {
            beforeEach(function(done) {
              this.collection = new coll;
              this.collection.fetch();
            });

            if(run === true) {
              it("fetch", function(done) {
                expect(this.collection.length).toBeGreaterThan(0);
                done();
              });
            } else {
              xit("fetch", function(done) {
                expect(this.collection.length).toBeGreaterThan(0);
                done();
              });
            }
          });
        }

        var arg = true;
        describeFetch("Providers", Providers, arg);
        describeFetch("Projects", Projects, arg);
        describeFetch("Images", Images, arg);
        describeFetch("Servers", Servers, arg);
        describeFetch("Flavors", Flavors, arg);
        describeFetch("Groups", Groups, arg);
        describeFetch("Users", Users, arg);
        describeFetch("Keys", Keys, arg);
        describeFetch("Scripts", Scripts, arg);
        describeFetch("Networks", Networks, arg);

      });

      describe("Images deep testing", function() {

        beforeEach( function() {
          this.collection = new Images();
        });


        it("URL is OK", function() {
          expect(this.collection.url).toEqual("/collections/images");
        });

        afterEach( function() {
          this.collection = undefined;
        });

      });

  });

});
