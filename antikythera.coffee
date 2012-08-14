###
Antikythera is a state machine built specifically to aid
in debugging race conditions and other bugs that tend to
happen between page states
###

class Antikythera

  options:
    development: false

  constructor: (@options) ->

  currentStage: ->
    if options.currentStage?
      @options.currentStage if @options.currentStage?
    else
      id: "default"

  go: (stageName, data)
    currentStage = @currentStage()
    return false if !stageName? or stageName == currentStage.id
    currentStage.out?()
    @options.currentStage = @stages[stageName]
    @options.currentStage.in?(data)
