# Content-Flow-ChildFlow

This document outlines how a `Flow` connects to `Content` and `ChildFlow`, the patterns enabling communication between them, and the task of creating ergonomic conveniences (factories) for generating `FlowEvent<Select, Never>`.

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
- **Bi-directional communication** is implemented using a `Binder` and `ContentFlowWitnesses`:
  - `Content` can send navigation or state-change requests to the flow.
  - The flow can notify the content of navigation dismissal or other changes.
- `ContentFlowWitnesses` defines 4 witness functions that handle this interaction:
  - **Content to Flow**: 
    - `emitting`: Sends events from content to the flow.
  - **Flow to Content**:
    - `dismissing`: Handles flow dismissal events.

### Potential Improvements
- Add a `bind` method as an extension on `ContentFlowWitnesses` to simplify the process of setting up connections.

---

## 2. Flow → ChildFlow (via `Node`)

### Connection Overview
- **Uni-directional communication** is implemented using a `Node`:
  - The parent flow reacts to changes in the child flow’s state.
  - This connection does not allow the child flow to respond to parent flow changes.
- The `Node` structure holds a reference to the child flow and subscribes to its state, enabling the parent flow to update itself as needed.

---

## Using `FlowEvent<Select, Never>`

### Event Design
- Both `Binder` and `Node` use `FlowEvent<Select, Never>` to communicate state changes or navigation events.
- Clients can choose whether `FlowEvent` includes an `isLoading` case:
  - **With `isLoading`**: Allows parent flows to update their `isLoading` property based on child or content events.
  - **Without `isLoading`**: Keeps `isLoading` logic localized to the child or content.

---

## Goal: Ergonomic Factories

The current goal is to create **factories** for generating `FlowEvent<Select, Never>` instances. These factories will:

1. Support creating events with `isLoading` toggles.
2. Support creating events without `isLoading` toggles.

### Benefits of Factories
- **Reduce boilerplate**: Simplify creating and managing `FlowEvent` instances in both `Binder` and `Node`.
- **Clarify intent**: Enable clients to explicitly opt in or out of parent-level `isLoading` behavior.

---

## Summary

This framework ensures clean, modular communication between `Flow`, `Content`, and `ChildFlow`. The ergonomic factory functions for `FlowEvent<Select, Never>` will streamline client usage, making it easier to configure whether parent flows reflect child or content `isLoading` states. Clients retain flexibility by choosing the appropriate factory or implementing custom `Node` and `Binder` configurations.
