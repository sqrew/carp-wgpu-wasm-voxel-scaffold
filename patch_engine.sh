#!/bin/bash
# Revert the damage
git checkout src/engine.carp

# Now apply properly
sed -i 's/(defn tick \[state win dt\]/(defn tick-update! [state win dt]\n    (do\n      (EngineState.pre-update! state win)\n      (let [input (EngineState.input state)] (EngineState.update! state input dt))\n      (EngineState.post-update! state)))\n\n  (defn tick-render! [state win]\n    (do\n      (EngineState.pre-render! state)\n      (EngineState.render! state)\n      (EngineState.post-render! state)))/' src/engine.carp
