# LoadStateMachine

This sub-module provides a generic loading state mechanism based on the reducer pattern. It includes:

- **LoadState**: An enum representing the states of a loading process:
  - `pending`
  - `loading(Success?)`
  - `completed(Success)`
  - `failure(Failure)`

- **LoadEvent**: An enum representing events that trigger state transitions:
  - `load`
  - `loaded(Result<Success, Failure>)`

- **LoadEffect**: An enum defining side effects (e.g., triggering a load).

- **LoadReducer**: Applies state transitions based on events and returns an updated state along with an optional effect.

- **LoadEffectHandler**: Executes side effects and dispatches events based on asynchronous outcomes.

Refer to the unit tests for usage examples and behavior verification.
