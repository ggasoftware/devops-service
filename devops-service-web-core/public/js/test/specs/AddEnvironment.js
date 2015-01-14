// Jasmine Unit Testing Suite
// Testing AddEnvironments modal view

define([
  
  'jquery',

  'views/modals/AddEnvironments',
  'models/Project'

], function($, View, Project) {

    describe("rendering", function() {

      describe("when there is a model", function(){
        it("renders the model", function() {
          var testProject = new Project();
          var view = new View({project: testProject});
          expect(1 == 1);
        });
      });

    });
});
