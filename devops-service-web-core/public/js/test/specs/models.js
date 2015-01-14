// Jasmine Unit Testing Suite
// Testing models

define([

  'models/Provider',
  'models/Image',
  'models/Project',
  'models/Server',
  'models/Flavor',
  'models/Group',
  'models/User',
  'models/Key',
  'models/Script',
  'models/Network',

], function(  Provider,
              Image,
              Project,
              Server,
              Flavor,
              Group,
              User,
              Key,
              Script,
              Network
             ) {

            describe("MODELS", function() {

                describe("Provider", function() {

                    beforeEach(function() {
                        this.model = new Provider();
                        spyOn(Provider.prototype, "validate").and.callThrough();
                    });

                    xit("should be in a valid state", function() {
                        expect(this.model.isValid()).toBe(true);
                    });

                    xit("should call the validate method when setting a property", function() {
                        this.model.set({ example: "test" }, { validate: true });
                        expect(Project.prototype.validate).toHaveBeenCalled();
                    });

                });


                describe("Image", function() {

                    beforeEach(function() {
                        this.model = new Image();
                        spyOn(Image.prototype, "validate").and.callThrough();
                    });

                    it("should be in a valid state", function() {
                        expect(this.model.isValid()).toBe(true);
                    });

                    it("should call the validate method when setting a property", function() {
                        this.model.set({ example: "test" }, { validate: true });
                        expect(Image.prototype.validate).toHaveBeenCalled();
                    });

                });

                describe("Project", function() {

                    beforeEach(function() {
                        this.model = new Project();
                        spyOn(Project.prototype, "validate").and.callThrough();
                    });

                    xit("should be in a valid state", function() {
                        expect(this.model.isValid()).toBe(true);
                    });

                    xit("should call the validate method when setting a property", function() {
                        this.model.set({ example: "test" }, { validate: true });
                        expect(Project.prototype.validate).toHaveBeenCalled();
                    });

                });

                describe("Server", function() {

                    beforeEach(function() {
                        this.model = new Server();
                        spyOn(Server.prototype, "validate").and.callThrough();
                    });

                    xit("should be in a valid state", function() {
                        expect(this.model.isValid()).toBe(true);
                    });

                    xit("should call the validate method when setting a property", function() {
                        this.model.set({ example: "test" }, { validate: true });
                        expect(Server.prototype.validate).toHaveBeenCalled();
                    });

                });

                describe("Flavor", function() {

                    beforeEach(function() {
                        this.model = new Flavor();
                        spyOn(Flavor.prototype, "validate").and.callThrough();
                    });

                    xit("should be in a valid state", function() {
                        expect(this.model.isValid()).toBe(true);
                    });

                    xit("should call the validate method when setting a property", function() {
                        this.model.set({ example: "test" }, { validate: true });
                        expect(Flavor.prototype.validate).toHaveBeenCalled();
                    });

                });

                describe("Group", function() {

                    beforeEach(function() {
                        this.model = new Group();
                        spyOn(Group.prototype, "validate").and.callThrough();
                    });

                    xit("should be in a valid state", function() {
                        expect(this.model.isValid()).toBe(true);
                    });

                    xit("should call the validate method when setting a property", function() {
                        this.model.set({ example: "test" }, { validate: true });
                        expect(Group.prototype.validate).toHaveBeenCalled();
                    });

                });

                describe("User", function() {

                    beforeEach(function() {
                        this.model = new User();
                        spyOn(User.prototype, "validate").and.callThrough();
                    });

                    xit("should be in a valid state", function() {
                        expect(this.model.isValid()).toBe(true);
                    });

                    xit("should call the validate method when setting a property", function() {
                        this.model.set({ example: "test" }, { validate: true });
                        expect(User.prototype.validate).toHaveBeenCalled();
                    });

                });

                describe("Key", function() {

                    beforeEach(function() {
                        this.model = new Key();
                        spyOn(Key.prototype, "validate").and.callThrough();
                    });

                    xit("should be in a valid state", function() {
                        expect(this.model.isValid()).toBe(true);
                    });

                    xit("should call the validate method when setting a property", function() {
                        this.model.set({ example: "test" }, { validate: true });
                        expect(Key.prototype.validate).toHaveBeenCalled();
                    });

                });

                describe("Script", function() {

                    beforeEach(function() {
                        this.model = new Script();
                        spyOn(Script.prototype, "validate").and.callThrough();
                    });

                    xit("should be in a valid state", function() {
                        expect(this.model.isValid()).toBe(true);
                    });

                    xit("should call the validate method when setting a property", function() {
                        this.model.set({ example: "test" }, { validate: true });
                        expect(Script.prototype.validate).toHaveBeenCalled();
                    });

                });

                describe("Network", function() {

                    beforeEach(function() {
                        this.model = new Network();
                        spyOn(Network.prototype, "validate").and.callThrough();
                    });

                    xit("should be in a valid state", function() {
                        expect(this.model.isValid()).toBe(true);
                    });

                    xit("should call the validate method when setting a property", function() {
                        this.model.set({ example: "test" }, { validate: true });
                        expect(Network.prototype.validate).toHaveBeenCalled();
                    });

                });

            }); 

});
