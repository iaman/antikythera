// Generated by CoffeeScript 1.3.3
var Antikythera;

Antikythera = (function() {

  function Antikythera(options) {
    this.options = options;
    this.stages = {};
    this.stageQueue = [];
    this.currentStage = {
      name: "default",
      transitionIn: function() {},
      transitionOut: function() {}
    };
    this.history = [
      {
        transitionedIn: this.currentStage
      }
    ];
    this.position = 0;
  }

  Antikythera.prototype.crank = function() {
    var stage, _ref, _ref1;
    if (!((_ref = this.options) != null ? _ref.development : void 0)) {
      return false;
    }
    if (this._present || this.position === ((_ref1 = this.stageQueue[0]) != null ? _ref1.position : void 0)) {
      if (!(this.stageQueue.length > 0)) {
        return false;
      }
      stage = this.stageQueue.shift();
      if (this._present) {
        this._log(this.stages[stage.name], stage.data);
      }
      return this._transition(this.stages[stage.name], stage.data);
    } else {

    }
  };

  Antikythera.prototype.go = function(name, data) {
    var _ref;
    if ((_ref = this.options) != null ? _ref.development : void 0) {
      return this._queue(name, this.position, data);
    }
    if (!(name != null) || name === this.currentStage.name) {
      return false;
    }
    this._log(this.stages[name], data);
    return this._transition(this.stages[name], data);
  };

  Antikythera.prototype.rewind = function() {
    var _ref, _ref1, _ref2;
    if (!((this.history.length > 1) && ((_ref = this.options) != null ? _ref.development : void 0))) {
      return false;
    }
    this.position--;
    return this._transition((_ref1 = this.history[this.position]) != null ? _ref1.transitionedIn : void 0, {
      "in": (_ref2 = this.history[this.position]) != null ? _ref2.dataIn : void 0
    });
  };

  Antikythera.prototype.stage = function(name, transitionIn, transitionOut) {
    return this.stages[name] = {
      name: name,
      transitionIn: transitionIn,
      transitionOut: transitionOut
    };
  };

  Antikythera.prototype._log = function(stage, data) {
    this.history.push({
      dataIn: data != null ? data["in"] : void 0,
      dataOut: data != null ? data.out : void 0,
      position: this.history.length,
      transitionedOut: this.currentStage,
      transitionedIn: stage
    });
    return this.position++;
  };

  Antikythera.prototype._present = function() {
    if (this.position === (this.history.length - 1)) {
      return true;
    }
  };

  Antikythera.prototype._queue = function(name, position, data) {
    this.stageQueue.push({
      name: name,
      position: position,
      data: data
    });
    return this.stageQueue.sort(function(a, b) {
      return a.position - b.position;
    });
  };

  Antikythera.prototype._transition = function(stage, data) {
    var _base;
    if (typeof (_base = this.currentStage).transitionOut === "function") {
      _base.transitionOut(data != null ? data.out : void 0);
    }
    this.currentStage = stage;
    if (typeof stage.transitionIn === "function") {
      stage.transitionIn(data != null ? data["in"] : void 0);
    }
    return true;
  };

  return Antikythera;

})();