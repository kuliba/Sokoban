//
//  EffectHandlerSpy.swift
//
//
//  Created by Igor Malyarov on 20.01.2024.
//

final class EffectHandlerSpy<Event, Effect> {
    
    private(set) var messages = [Message]()
}

extension EffectHandlerSpy {
    
    var callCount: Int { messages.count }
    var effects: [Effect] { messages.map(\.effect) }
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        messages.append((effect, dispatch))
    }
    
    func complete(
        with event: Event,
        at index: Int = 0
    ) {
        messages[index].dispatch(event)
    }
}

extension EffectHandlerSpy {
    
    typealias Dispatch = (Event) -> Void
    typealias Message = (effect: Effect, dispatch: Dispatch)
}
