//
//  RxComposition.swift
//
//
//  Created by Igor Malyarov on 20.01.2024.
//

import RxViewModel

// Domain Composed

private struct ComposedState: Equatable {
    
    var aState: AState
    var bState: BState
}

private enum ComposedEvent: Equatable {
    
    case aEvent(AEvent)
    case bEvent(BEvent)
}

private enum ComposedEffect: Equatable {
    
    case aEffect(AEffect)
    case bEffect(BEffect)
}

private final class ComposedReducer {
    
    private let aReducer: AReducer
    private let bReducer: BReducer
    
    init(
        aReducer: AReducer,
        bReducer: BReducer
    ) {
        self.aReducer = aReducer
        self.bReducer = bReducer
    }
}

extension ComposedReducer: Reducer {
    
    func reduce(
        _ state: ComposedState,
        _ event: ComposedEvent
    ) -> (ComposedState, ComposedEffect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case let .aEvent(aEvent):
            let (aState, aEffect) = aReducer.reduce(state.aState, aEvent)
            state.aState = aState
            effect = aEffect.map(ComposedEffect.aEffect)
            
        case let .bEvent(bEvent):
            let (bState, bEffect) = bReducer.reduce(state.bState, bEvent)
            state.bState = bState
            effect = bEffect.map(ComposedEffect.bEffect)
        }
        
        return (state, effect)
    }
}

private final class ComposedEffectHandler {
    
    let aEffectHandler: AEffectHandler
    let bEffectHandler: BEffectHandler
    
    init(
        aEffectHandler: AEffectHandler,
        bEffectHandler: BEffectHandler
    ) {
        self.aEffectHandler = aEffectHandler
        self.bEffectHandler = bEffectHandler
    }
}

extension ComposedEffectHandler: EffectHandler {
    
    typealias Dispatch = (ComposedEvent) -> Void
    
    func handleEffect(
        _ effect: ComposedEffect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case let .aEffect(aEffect):
            aEffectHandler.handleEffect(aEffect) { dispatch(.aEvent($0)) }
            
        case let .bEffect(bEffect):
            bEffectHandler.handleEffect(bEffect) { dispatch(.bEvent($0)) }
        }
    }
}

private typealias ComposedViewModel = RxViewModel<ComposedState, ComposedEvent, ComposedEffect>

// Domain A

private struct AState: Equatable {
    
    var value: Int
}

private enum AEvent: Equatable {
    
    case increase
}

private enum AEffect: Equatable {
    
    case ping
}

private final class AReducer {}

extension AReducer: Reducer {
    
    func reduce(
        _ state: AState,
        _ event: AEvent
    ) -> (AState, AEffect?) {
        
        var state = state
        
        switch event {
        case .increase:
            state.value += 1
        }
        
        return (state, nil)
    }
}

private final class AEffectHandler {}

extension AEffectHandler: EffectHandler {
    
    typealias Dispatch = (AEvent) -> Void
    
    func handleEffect(
        _ effect: AEffect,
        _ dispatch: @escaping Dispatch
    ) {
        // ...
    }
}

private typealias AViewModel = RxViewModel<AState, AEvent, AEffect>

// Domain B

private struct BState: Equatable {
    
    var value: String
}

private enum BEvent: Equatable {
    
    case update(String)
}

private enum BEffect: Equatable {
    
    case pong
}

private final class BReducer {}
extension BReducer: Reducer {
    
    func reduce(
        _ state: BState,
        _ event: BEvent
    ) -> (BState, BEffect?) {
        
        var state = state
        
        switch event {
        case let .update(value):
            state.value = value
        }
        
        return (state, nil)
    }
}

private final class BEffectHandler {}
extension BEffectHandler: EffectHandler {
    
    typealias Dispatch = (BEvent) -> Void
    
    func handleEffect(
        _ effect: BEffect,
        _ dispatch: @escaping Dispatch
    ) {
        // ...
    }
}

private typealias BViewModel = RxViewModel<AState, AEvent, BEffect>

private func makeComposedViewModel() -> ComposedViewModel {
    
    let composedReducer = ComposedReducer(
        aReducer: .init(),
        bReducer: .init()
    )
    let composedEffectHandler = ComposedEffectHandler(
        aEffectHandler: .init(),
        bEffectHandler: .init()
    )
    
    return .init(
        initialState: .init(
            aState: .init(value: 0),
            bState: .init(value: "")
        ),
        reducer: composedReducer,
        effectHandler: composedEffectHandler
    )
}
