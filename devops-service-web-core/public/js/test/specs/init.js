// Jasmine Unit Testing Suite
//  
// Testing App-init

define([
  'App',

], function(App) {

    describe("Load and init application modules", function() {
        describe("Marionette App instantiation", function() {
            App.start();
            it("App should start and have Regions", function() {
                expect(App.workspaceRegion.el).toEqual("#workspace");
                expect(App.consoleRegion.el).toEqual("#console-body");
            });
        });

    });

});
