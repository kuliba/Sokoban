# Content-Flow-ChildFlow

This document outlines how a `Flow` connects to `Content` and `ChildFlow`, the patterns enabling communication between them, and the current state of ergonomic conveniences (factories) for generating `FlowEvent<Select, Never>`.

---

## Overview

Each `Flow` can connect to:

1. **Content** (bi-directional):
   - Content can inform the flow of navigation requests or other state changes.
   - The flow can inform the content that navigation has been dismissed, allowing the content to update its state.

2. **ChildFlow** (uni-directional):
   - The parent flow observes and reacts to changes in the child flow’s state, updating its own state accordingly.
   - The child flow does not observe or react to changes in the parent flow.

---

## 1. Content ↔ Flow (via `Binder`)

### Connection Overview
- **Bi-directional communication** is implemented using a `Binder` approach alongside types like `ContentFlowWitnesses`:
  - `Content` can send navigation or state-change requests to the flow.
  - The flow can notify the content of navigation dismissal or other updates.
- `ContentFlowWitnesses` defines four witness functions:
  - `contentEmitting`, `contentDismissing`, `flowEmitting`, `flowReceiving`.
- These witnesses, combined with `ContentFlowBindingFactory` or `ContentWitnesses`, enable high-level `bind` methods for straightforward setup.

### Implemented Features
- **Factories for binding**: 
  - `ContentFlowBindingFactory` now includes multiple `bind` methods to simplify linking content and flow.
  - The factory supports scenarios with and without `isLoading` or `dismiss`.

---

## 2. Flow → ChildFlow (via `Node`)

### Connection Overview
- **Uni-directional communication** is implemented through a `Node`:
  - The parent flow subscribes to the child flow’s state changes.
  - The child flow does not observe or respond to the parent flow.
- This structure allows the parent to update its own state whenever the child emits new navigation or loading events (if present).

---

## Using `FlowEvent<Select, Never>`

### Event Design
- Both the `Binder` approach and `Node` use `FlowEvent<Select, Never>` to signal navigation or loading updates.
- Clients decide whether or not to use an `isLoading` case inside `FlowEvent`, based on their domain needs:
  - **With `isLoading`**: Parent flows can reflect the child or content’s loading state.
  - **Without `isLoading`**: The child or content handles loading state privately, and the parent focuses on navigation alone.

---

## Factories and Bindings

### Implemented Factories
- **`ContentFlowBindingFactory`**: Provides multiple `bind` methods to connect `Content` and `Flow`, including:
  - Scenarios without `isLoading` or `dismiss`.
  - Scenarios where `FlowEvent<Select, Never>` is used directly.

### Benefits
- **Reduced Boilerplate**: The `bind` methods handle typical streaming connections, so clients don’t need to manually set up Combine pipelines.
- **Flexibility**: By allowing `FlowEvent` to include or exclude certain cases, each flow can opt into parent-level loading management or keep it local.

---

## Summary

The **Content-Flow-ChildFlow** approach ensures clear, modular communication among `Flow`, `Content`, and `ChildFlow`. With the **`ContentFlowBindingFactory`** and corresponding `bind` extensions:
- **Content** can effortlessly emit events (e.g., `select`, `isLoading`, `dismiss`) to the flow.
- **Flow** can notify content of navigation dismissal or other changes.
- **ChildFlow** remains a unidirectional source of state updates, observed by the parent flow via a `Node`.

Clients retain control over how or whether `isLoading` is surfaced, enabling both minimal setups (pure navigation) and more complete setups (loading spinners, dismiss flows) through these factories.
