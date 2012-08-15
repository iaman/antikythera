# Antikythera is a state machine built specifically to aid
# in debugging race conditions and other bugs that tend to
# happen between and during particular stages in the life
# of your page

class Antikythera

  currentStage:
    name: "default"

  constructor: (@options) ->
    @stages = {}
    @stageQueue = []
    @currentStage = @currentStage

  go: (name, data) ->
    return @stageQueue.push({name, data}) if @options?.development
    return false if !name? or name == @currentStage.name

    @_transition(@stages[name], data)

  stage: (name, transitionIn, transitionOut) ->
    @stages[name] =
      name: name
      transitionIn: transitionIn
      transitionOut: transitionOut

  crank: ->
    return false unless @stageQueue.length > 0
    stage = @stageQueue.shift()
    return @_transition(@stages[stage.name], stage.data)

  _transition: (stage, data) ->
    @currentStage.transitionOut?(data?.out)
    @currentStage = stage
    stage.transitionIn?(data?.in)
    true
