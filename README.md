Antikythera
===========

Antikythera is a tool built specifically to aid in debugging race conditions and other bugs that tend to happen between and during particular stages in the life of your page

## Spinning up an Antikythera

Making a new Antikythera is super easy. Most of the time, it's going to look like this:

```javascript
blah = new Antikythera();
```

An Antikythera can also be spun up in development mode by passing it a hash like this:

```javascript
blah = new Antikythera({ development: true });
```

Development mode will enforce a roadblock on transitioning between stages until you're ready to move on. It doesn't use breakpoints or debuggers, so you'll maintain all of the interaction you'd expect on your page while you're debugging it.

## Creating a stage

Setting up an Antikythera is all well and good, but it doesn't mean a thing unless you give it some stages to go between! Creating a stage is super simple; all you have to do is give it a name, a function that will handle the transition into that stage, and a function to handle the transition out of that stage:

```javascript
function transitionIn() { ... }
function transitionOut() { ... }

blah.stage("stuff", transitionIn, transitionOut);
```

A stage's transition functions can also optionally accept data. Let's set up another stage with a transition that can take data:

```javascript
function otherIn() { ... }
function otherOut(data) { ... } // Does something with the data

blah.stage("things", otherIn, otherOut);
```

It's best to make your stages as discrete as possible, so try to make sure to include everything you'd need to back out of a stage in the transitionOut function: unbinding event listeners, DOM cleanup, et cetera. If you find yourself thinking that there are things you wouldn't want to clean up transitioning out of a stage, you're probably in a __subflow__, and you might want to spin up a new Antikythera to handle discrete changes that are internal to that subflow.

## Transitioning between stages

Once you've set up an Antikythera and pumped a few stages in, it's time to start transitioning between them! Let's see an example:

```javascript
blah.go("stuff");
```

Assuming you've just spun up this Antikythera and given it a few stages, this will run the **transitionIn()** function we created up above. Let's try going to a different stage:

```javascript
blah.go("things");
```

Now, since we were in the "stuff" stage, this will run **transitionOut()** and then **otherIn()**, putting us into the "things" stage! Finally, let's try giving a transition some data:

```javascript
blah.go("stuff", { out: { hammerTime: true } });
```

This time, we'll call **otherOut()** with the argument __{ hammerTime: true }__, then **transitionIn()** without any data.

## Development mode

If you set up an Antikythera in development mode, you already know that it will impose roadblocks upon your transitions. When it does this, it pushes those transition requests into a queue that you may manually execute using its **crank** method:

```javascript
blah.crank();
```

Crank will shift the first request out of the queue and execute it. Subsequent requests can be handled with more calls to the **crank** method.
