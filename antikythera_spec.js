// Generated by CoffeeScript 1.3.3

describe("Antikythera", function() {
  var transitionIn, transitionOut;
  transitionIn = function() {};
  transitionOut = function() {};
  describe("constructor", function() {
    it("creates an Antikythera", function() {
      var blah;
      blah = new Antikythera();
      return expect(blah instanceof Antikythera).toBeTruthy;
    });
    return it("creates an Antikythera in development mode", function() {
      var blah;
      blah = new Antikythera({
        development: true
      });
      return expect(blah.options.development).toBeTruthy;
    });
  });
  describe("crank", function() {
    beforeEach(function() {
      this.blah = new Antikythera({
        development: true
      });
      return this.blah.stage("stuff", transitionIn, transitionOut);
    });
    it("returns false if the Antikythera is not in development mode", function() {
      var blah;
      blah = new Antikythera();
      blah.stageQueue.push("stuff");
      return expect(blah.crank()).toBeFalsy;
    });
    it("returns false if there's nothing in the queue", function() {
      return expect(this.blah.crank()).toBeFalsy;
    });
    it("logs the transition if the Antikythera is in the present", function() {
      spyOn(this.blah, "_log");
      this.blah.go("stuff");
      this.blah.crank();
      return expect(this.blah._log).toHaveBeenCalledWith(this.blah.stages["stuff"], void 0);
    });
    it("shifts a transition out of the queue and fires it off", function() {
      this.blah.go("stuff");
      spyOn(this.blah, "_transition");
      this.blah.crank();
      return expect(this.blah._transition).toHaveBeenCalledWith(this.blah.stages["stuff"], void 0);
    });
    return it("shifts a transition with data out of the queue and fires it off", function() {
      this.blah.go("stuff", {
        "in": "hello",
        out: "goodbye"
      });
      spyOn(this.blah, "_transition");
      this.blah.crank();
      return expect(this.blah._transition).toHaveBeenCalledWith(this.blah.stages["stuff"], {
        "in": "hello",
        out: "goodbye"
      });
    });
  });
  describe("go", function() {
    beforeEach(function() {
      return this.blah = new Antikythera();
    });
    it("queues a transition up if the Antikythera is in dev mode", function() {
      spyOn(this.blah, "_queue");
      this.blah.options = {
        development: true
      };
      this.blah.go("stuff");
      return expect(this.blah._queue).toHaveBeenCalledWith("stuff", 0, void 0);
    });
    it("returns false if the requested stage is the current stage", function() {
      return expect(this.blah.go("default")).toBeFalsy;
    });
    it("logs the transition made", function() {
      spyOn(this.blah, "_log");
      this.blah.stage("stuff", transitionIn, transitionOut);
      this.blah.go("stuff");
      return expect(this.blah._log).toHaveBeenCalledWith(this.blah.stages["stuff"], void 0);
    });
    it("logs the data for a transition", function() {
      spyOn(this.blah, "_log");
      this.blah.stage("stuff", transitionIn, transitionOut);
      this.blah.go("stuff", {
        "in": "hello",
        out: "goodbye"
      });
      return expect(this.blah._log).toHaveBeenCalledWith(this.blah.stages["stuff"], {
        "in": "hello",
        out: "goodbye"
      });
    });
    it("fires a transition into a stage", function() {
      spyOn(this.blah, "_transition");
      this.blah.stage("stuff", transitionIn, transitionOut);
      this.blah.go("stuff");
      return expect(this.blah._transition).toHaveBeenCalledWith(this.blah.stages["stuff"], void 0);
    });
    return it("fires a transition into a stage with data", function() {
      spyOn(this.blah, "_transition");
      this.blah.stage("stuff", transitionIn, transitionOut);
      this.blah.go("stuff", {
        "in": "hello",
        out: "goodbye"
      });
      return expect(this.blah._transition).toHaveBeenCalledWith(this.blah.stages["stuff"], {
        "in": "hello",
        out: "goodbye"
      });
    });
  });
  describe("rewind", function() {
    beforeEach(function() {
      this.blah = new Antikythera({
        development: true
      });
      this.blah.stage("stuff", transitionIn, transitionOut);
      return this.blah.stage("things", transitionIn, transitionOut);
    });
    it("returns false if there's no history", function() {
      return expect(this.blah.rewind()).toBeFalsy;
    });
    it("returns false if the Antikythera is not in development mode", function() {
      this.blah.options.development = false;
      this.blah.go("stuff");
      return expect(this.blah.rewind()).toBeFalsy;
    });
    it("fires off a transition", function() {
      spyOn(this.blah, "_transition");
      this.blah.go("things");
      this.blah.crank();
      this.blah.rewind();
      return expect(this.blah._transition.calls.length).toEqual(2);
    });
    it("fires off a transition with the data that was originally passed into it", function() {
      spyOn(this.blah, "_transition");
      this.blah.go("things", {
        "in": "hello",
        out: "goodbye"
      });
      this.blah.go("stuff");
      this.blah.crank();
      this.blah.crank();
      this.blah.rewind();
      return expect(this.blah._transition.calls[2].args).toEqual([
        {
          name: "things",
          transitionIn: transitionIn,
          transitionOut: transitionOut
        }, {
          "in": "hello"
        }
      ]);
    });
    return it("decrements the Antikythera's position", function() {
      this.blah.go("stuff");
      this.blah.crank();
      expect(this.blah.position).toEqual(1);
      this.blah.rewind();
      return expect(this.blah.position).toEqual(0);
    });
  });
  describe("stage", function() {
    return it("pushes a stage into the stages hash", function() {
      var blah;
      blah = new Antikythera();
      blah.stage("stuff", transitionIn, transitionOut);
      return expect(blah.stages["stuff"]).toEqual({
        name: "stuff",
        transitionIn: transitionIn,
        transitionOut: transitionOut
      });
    });
  });
  describe("_log", function() {
    beforeEach(function() {
      this.blah = new Antikythera();
      return this.blah._log({
        name: "stuff",
        transitionIn: transitionIn,
        transitionOut: transitionOut
      }, {
        "in": "hello",
        out: "goodbye"
      });
    });
    it("logs the data for a transition", function() {
      expect(this.blah.history[1].dataIn).toEqual("hello");
      expect(this.blah.history[1].dataOut).toEqual("goodbye");
      expect(this.blah.history[1].position).toEqual(1);
      return expect(this.blah.history[1].transitionedIn).toEqual({
        name: "stuff",
        transitionIn: transitionIn,
        transitionOut: transitionOut
      });
    });
    return it("increments the position", function() {
      return expect(this.blah.position).toEqual(1);
    });
  });
  describe("_present", function() {
    beforeEach(function() {
      return this.blah = new Antikythera({
        development: true
      });
    });
    it("returns true if the Antikythera's position is at the top of the history", function() {
      return expect(this.blah._present()).toBeTruthy();
    });
    return it("returns falsy if the Antikythera's position is not at the top of the history", function() {
      this.blah.stage("stuff", transitionIn, transitionOut);
      this.blah.go("stuff");
      this.blah.crank();
      this.blah.rewind();
      return expect(this.blah._present()).toBeFalsy();
    });
  });
  describe("_queue", function() {
    beforeEach(function() {
      return this.blah = new Antikythera();
    });
    it("adds a transition to the stageQueue", function() {
      this.blah._queue("stuff", 0, void 0);
      expect(this.blah.stageQueue.length).toEqual(1);
      return expect(this.blah.stageQueue[0]).toEqual({
        name: "stuff",
        position: 0,
        data: void 0
      });
    });
    return it("automatically sorts transitions by their position in history", function() {
      this.blah._queue("stuff", 1, void 0);
      this.blah._queue("things", 0, void 0);
      expect(this.blah.stageQueue.length).toEqual(2);
      expect(this.blah.stageQueue[0]).toEqual({
        name: "things",
        position: 0,
        data: void 0
      });
      return expect(this.blah.stageQueue[1]).toEqual({
        name: "stuff",
        position: 1,
        data: void 0
      });
    });
  });
  return describe("_transition", function() {
    beforeEach(function() {
      return this.blah = new Antikythera();
    });
    it("executes a transition out of the previous stage and into the next", function() {
      var goIn, goOut;
      goIn = jasmine.createSpy("goIn");
      goOut = jasmine.createSpy("goOut");
      this.blah.stage("stuff", transitionIn, goOut);
      this.blah.stage("things", goIn, transitionOut);
      this.blah.go("stuff");
      this.blah.go("things");
      expect(goOut).toHaveBeenCalled();
      return expect(goIn).toHaveBeenCalled();
    });
    it("sets the current stage to the new one", function() {
      this.blah.stage("stuff", transitionIn, transitionOut);
      this.blah.go("stuff");
      return expect(this.blah.currentStage.name).toEqual("stuff");
    });
    return it("returns true", function() {
      this.blah.stage("stuff", transitionIn, transitionOut);
      return expect(this.blah.go("stuff")).toBeTruthy;
    });
  });
});
