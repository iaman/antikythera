describe "Antikythera", ->

  transitionIn = ->
  transitionOut = ->

  describe "constructor", ->

    it "creates an Antikythera", ->
      blah = new Antikythera()
      expect(blah instanceof Antikythera).toEqual true

    it "creates an Antikythera in development mode", ->
      blah = new Antikythera
        development: true
      expect(blah.options.development).toEqual true


  describe "stage", ->
  
    it "pushes a stage into the stages hash", ->
      blah = new Antikythera()
      blah.stage "stuff", transitionIn, transitionOut

      expect(blah.stages["stuff"]).toEqual
        name: "stuff"
        transitionIn: transitionIn
        transitionOut: transitionOut


  describe "go", ->

    beforeEach ->
      @blah = new Antikythera()

    it "fires a transition into a stage", ->
      spyOn @blah, "_transition"
      @blah.stage "stuff", transitionIn, transitionOut
      @blah.go "stuff"

      expect(@blah._transition).toHaveBeenCalledWith(@blah.stages["stuff"], undefined)

    it "queues a transition up if the Antikythera is in dev mode", ->
      @blah.options =
        development: true
      @blah.go "stuff"

      expect(@blah.stageQueue.length).toEqual 1

    it "returns false if the requested stage is the current stage", ->
      expect(@blah.go("default")).toEqual false


  describe "crank", ->

    beforeEach ->
      @blah = new Antikythera
        development: true
      @blah.stage "stuff", transitionIn, transitionOut

    it "shifts a transition out of the queue and fires it off", ->
      @blah.go "stuff"
      spyOn @blah, "_transition"
      @blah.crank()

      expect(@blah._transition).toHaveBeenCalledWith(@blah.stages["stuff"], undefined)

    it "returns false if there's nothing in the queue", ->
      expect(@blah.crank()).toEqual false


  describe "_transition", ->

    beforeEach ->
      @blah = new Antikythera()

    it "executes a transition into a stage", ->
      goIn = jasmine.createSpy "goIn"
      @blah.stage "stuff", goIn, transitionOut
      @blah.go "stuff"

      expect(goIn).toHaveBeenCalled()

    it "sets the current stage to the new one", ->
      @blah.stage "stuff", transitionIn, transitionOut
      @blah.go "stuff"

      expect(@blah.currentStage.name).toEqual "stuff"

    it "executes a transition out of the previous stage and into the next", ->
      goIn = jasmine.createSpy "goIn"
      goOut = jasmine.createSpy "goOut"
      @blah.stage "stuff", transitionIn, goOut
      @blah.stage "things", goIn, transitionOut
      @blah.go "stuff"
      @blah.go "things"

      expect(goOut).toHaveBeenCalled()
      expect(goIn).toHaveBeenCalled()
