describe "Antikythera", ->

  transitionIn = ->
  transitionOut = ->

  describe "constructor", ->

    it "creates an Antikythera", ->
      blah = new Antikythera()
      expect(blah instanceof Antikythera).toBeTruthy

    it "creates an Antikythera in development mode", ->
      blah = new Antikythera
        development: true
      expect(blah.options.development).toBeTruthy


  describe "crank", ->

    beforeEach ->
      @blah = new Antikythera
        development: true
      @blah.stage "stuff", transitionIn, transitionOut

    it "returns false if the Antikythera is not in development mode", ->
      blah = new Antikythera()
      blah.stageQueue.push("stuff")

      expect(blah.crank()).toBeFalsy()

    it "returns false if there's nothing in the queue", ->
      expect(@blah.crank()).toBeFalsy()

    it "logs the transition if the Antikythera is in the present", ->
      spyOn @blah, "_log"
      @blah.go "stuff"
      @blah.crank()

      expect(@blah._log).toHaveBeenCalledWith @blah.stages["stuff"], undefined

    it "shifts a transition out of the queue and fires it off", ->
      @blah.go "stuff"
      spyOn @blah, "_transition"
      @blah.crank()

      expect(@blah._transition).toHaveBeenCalledWith @blah.stages["stuff"], undefined

    it "shifts a transition with data out of the queue and fires it off", ->
      @blah.go "stuff", { in: "hello", out: "goodbye" }
      spyOn @blah, "_transition"
      @blah.crank()

      expect(@blah._transition).toHaveBeenCalledWith @blah.stages["stuff"], { in: "hello", out: "goodbye" }

    describe "when called in a previous stage", ->

      it "returns the stage to the canon historical stage before trying to progress through history", ->
        @blah.stage "things", transitionIn, transitionOut
        @blah.go "stuff"
        @blah.crank()
        @blah.rewind()
        @blah.go "things"
        @blah.crank()
        spyOn @blah, "_transition"
        @blah.crank()

        expect(@blah._transition.calls[0].args).toEqual [ @blah.history[0].transitionedIn, { in: undefined } ]

      it "progresses one stage forward through the history", ->
        @blah.go "stuff"
        @blah.crank()
        @blah.rewind()
        spyOn @blah, "_transition"
        @blah.crank()

        expect(@blah.position).toEqual 1
        expect(@blah._transition.calls[0].args).toEqual [ @blah.stages["stuff"], { in: undefined, out: undefined }]


  describe "go", ->

    beforeEach ->
      @blah = new Antikythera()

    it "queues a transition up if the Antikythera is in dev mode", ->
      spyOn @blah, "_queue"
      @blah.options =
        development: true
      @blah.go "stuff"

      expect(@blah._queue).toHaveBeenCalledWith "stuff", 0, undefined

    it "returns false if the requested stage is the current stage", ->
      expect(@blah.go("default")).toBeFalsy()

    it "logs the transition made", ->
      spyOn @blah, "_log"
      @blah.stage "stuff", transitionIn, transitionOut
      @blah.go "stuff"

      expect(@blah._log).toHaveBeenCalledWith @blah.stages["stuff"], undefined

    it "logs the data for a transition", ->
      spyOn @blah, "_log"
      @blah.stage "stuff", transitionIn, transitionOut
      @blah.go "stuff", { in: "hello", out: "goodbye" }

      expect(@blah._log).toHaveBeenCalledWith @blah.stages["stuff"], { in: "hello", out: "goodbye" }

    it "fires a transition into a stage", ->
      spyOn @blah, "_transition"
      @blah.stage "stuff", transitionIn, transitionOut
      @blah.go "stuff"

      expect(@blah._transition).toHaveBeenCalledWith @blah.stages["stuff"], undefined

    it "fires a transition into a stage with data", ->
      spyOn @blah, "_transition"
      @blah.stage "stuff", transitionIn, transitionOut
      @blah.go "stuff", { in: "hello", out: "goodbye" }

      expect(@blah._transition).toHaveBeenCalledWith @blah.stages["stuff"], { in: "hello", out: "goodbye" }


  describe "rewind", ->

    beforeEach ->
      @blah = new Antikythera
        development: true
      @blah.stage "stuff", transitionIn, transitionOut
      @blah.stage "things", transitionIn, transitionOut

    it "returns false if there's no history", ->
      expect(@blah.rewind()).toBeFalsy()

    it "returns false if you've already gone back to the first stage", ->
      @blah.go "stuff"
      @blah.crank()
      @blah.rewind()

      expect(@blah.rewind()).toBeFalsy()

    it "returns false if the Antikythera is not in development mode", ->
      @blah.options.development = false
      @blah.go "stuff"

      expect(@blah.rewind()).toBeFalsy()

    it "fires off a transition", ->
      spyOn @blah, "_transition"
      @blah.go "things"
      @blah.crank()
      @blah.rewind()

      expect(@blah._transition.calls.length).toEqual 2

    it "fires off a transition with the data that was originally passed into it", ->
      spyOn @blah, "_transition"
      @blah.go "things", { in: "hello", out: "goodbye" }
      @blah.go "stuff"
      @blah.crank()
      @blah.crank()
      @blah.rewind()

      expect(@blah._transition.calls[2].args).toEqual [
        name: "things"
        transitionIn: transitionIn
        transitionOut: transitionOut
      ,
        in: "hello"
      ]

    it "decrements the Antikythera's position", ->
      @blah.go "stuff"
      @blah.crank()

      expect(@blah.position).toEqual 1

      @blah.rewind()

      expect(@blah.position).toEqual 0


  describe "stage", ->
  
    it "pushes a stage into the stages hash", ->
      blah = new Antikythera()
      blah.stage "stuff", transitionIn, transitionOut

      expect(blah.stages["stuff"]).toEqual
        name: "stuff"
        transitionIn: transitionIn
        transitionOut: transitionOut


  describe "_log", ->

    beforeEach ->
      @blah = new Antikythera()
      @blah._log
        name: "stuff"
        transitionIn: transitionIn
        transitionOut: transitionOut
      ,
        in: "hello"
        out: "goodbye"

    it "logs the data for a transition", ->
      expect(@blah.history[1].dataIn).toEqual "hello"
      expect(@blah.history[1].dataOut).toEqual "goodbye"
      expect(@blah.history[1].position).toEqual 1
      expect(@blah.history[1].transitionedIn).toEqual
        name: "stuff"
        transitionIn: transitionIn
        transitionOut: transitionOut

    it "increments the position", ->
      expect(@blah.position).toEqual 1

    it "returns false if in the past", ->
      @blah.position--
      expect(@blah._log()).toBeFalsy()


  describe "_present", ->

    beforeEach ->
      @blah = new Antikythera
        development: true

    it "returns true if the Antikythera's position is at the top of the history", ->
      expect(@blah._present()).toBeTruthy()

    it "returns falsy if the Antikythera's position is not at the top of the history", ->
      @blah.stage "stuff", transitionIn, transitionOut
      @blah.go "stuff"
      @blah.crank()
      @blah.rewind()

      expect(@blah._present()).toBeFalsy()


  describe "_queue", ->

    beforeEach ->
      @blah = new Antikythera()

    it "adds a transition to the stageQueue", ->
      @blah._queue "stuff", 0, undefined

      expect(@blah.stageQueue.length).toEqual 1
      expect(@blah.stageQueue[0]).toEqual
        name: "stuff"
        position: 0
        data: undefined

    it "automatically sorts transitions by their position in history", ->
      @blah._queue "stuff", 1, undefined
      @blah._queue "things", 0, undefined

      expect(@blah.stageQueue.length).toEqual 2
      expect(@blah.stageQueue[0]).toEqual
        name: "things"
        position: 0
        data: undefined
      expect(@blah.stageQueue[1]).toEqual
        name: "stuff"
        position: 1
        data: undefined


  describe "_transition", ->

    beforeEach ->
      @blah = new Antikythera()

    it "executes a transition out of the previous stage and into the next", ->
      goIn = jasmine.createSpy "goIn"
      goOut = jasmine.createSpy "goOut"
      @blah.stage "stuff", transitionIn, goOut
      @blah.stage "things", goIn, transitionOut
      @blah.go "stuff"
      @blah.go "things"

      expect(goOut).toHaveBeenCalled()
      expect(goIn).toHaveBeenCalled()

    it "sets the current stage to the new one", ->
      @blah.stage "stuff", transitionIn, transitionOut
      @blah.go "stuff"

      expect(@blah.currentStage.name).toEqual "stuff"

    it "returns true", ->
      @blah.stage "stuff", transitionIn, transitionOut

      expect(@blah.go("stuff")).toBeTruthy
