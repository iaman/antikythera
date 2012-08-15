# Antikythera is a state machine built specifically to aid
# in debugging race conditions and other bugs that tend to
# happen between and during particular stages in the life
# of your page

class Antikythera

  options:
    development: false
    currentStage:
      id: "default"

  stages: {}

  stageQueue: []

  constructor: (options) ->
    @options.development = options?.development or @options.development

  go: (stageName, data) ->
    return @stageQueue.push({stageName, data}) if @options.development
    return false if !stageName? or stageName == @options.currentStage.id

    @_transition(@stages[stageName], data)

  stage: (stageName, transitionIn, transitionOut) ->
    @stages[stageName] =
      id: stageName
      in: transitionIn
      out: transitionOut

  crank: ->
    return "No queued stage transitions" unless @stageQueue.length > 0
    stage = @stageQueue.shift()
    return @_transition(@stages[stage.stageName], stage.data)

  _transition: (stage, data) ->
    @options.currentStage.out?(data?.out)
    @options.currentStage = stage
    stage.in?(data?.in)
