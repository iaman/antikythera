# Antikythera is a state machine built specifically to aid
# in debugging race conditions and other bugs that tend to
# happen between and during particular stages in the life
# of your page

class Antikythera

  constructor: (@options) ->
    @stages = {}
    @stageQueue = []
    @currentStage =
      name: "default"
      transitionIn: ->
      transitionOut: ->
    @history = [{transitionedIn: @currentStage}]
    @position = 0

  crank: ->
    return false unless @options?.development
    if @_present() or @position is @stageQueue[0]?.position
      return false unless (@stageQueue.length > 0)
      stage = @stageQueue.shift()
      @_log(@stages[stage.name], stage.data)
      return @_transition(@stages[stage.name], stage.data)
    else
      if @history[@position]?.transitionedIn isnt @currentStage
        @_transition @history[@position]?.transitionedIn, { in: @history[@position]?.dataIn }
      @position++
      @_transition @history[@position]?.transitionedIn, { in: @history[@position]?.dataIn, out: @history[@position]?.dataOut}

  go: (name, data) ->
    return @_queue(name, @position, data) if @options?.development
    return false if !name? or name == @currentStage.name
    @_log(@stages[name], data)
    @_transition(@stages[name], data)

  rewind: ->
    return false unless (@history.length > 1) and @position > 0 and @options?.development
    @position--
    @_transition @history[@position]?.transitionedIn, { in: @history[@position]?.dataIn }

  stage: (name, transitionIn, transitionOut) ->
    @stages[name] =
      name: name
      transitionIn: transitionIn
      transitionOut: transitionOut

  _log: (stage, data) ->
    return false unless @_present()
    @history.push
      dataIn: data?.in
      dataOut: data?.out
      position: @history.length
      transitionedOut: @currentStage
      transitionedIn: stage
    @position++

  _present: ->
    return true if @position is (@history.length - 1)

  _queue: (name, position, data) ->
    @stageQueue.push
      name: name
      position: position
      data: data
    @stageQueue.sort (a, b) ->
      return a.position - b.position

  _transition: (stage, data) ->
    @currentStage.transitionOut?(data?.out)
    @currentStage = stage
    stage.transitionIn?(data?.in)
    true

