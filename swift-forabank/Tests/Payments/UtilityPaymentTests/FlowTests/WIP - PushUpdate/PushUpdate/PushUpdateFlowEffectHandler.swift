//
//  PushUpdateFlowEffectHandler.swift
//
//
//  Created by Igor Malyarov on 14.03.2024.
//

public final class PushUpdateFlowEffectHandler<PushEvent, UpdateEvent, PushEffect, UpdateEffect> {
    
    private let push: Push
    private let update: Update
    
    public init(
        push: @escaping Push,
        update: @escaping Update
    ) {
        self.push = push
        self.update = update
    }
}

public extension PushUpdateFlowEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case let .push(pushEffect):
            push(pushEffect) { dispatch(.push($0)) }
            
        case let .update(updateEffect):
            update(updateEffect) { dispatch(.update($0)) }
        }
    }
}

public extension PushUpdateFlowEffectHandler {
    
    typealias PushDispatch = (PushEvent) -> Void
    typealias Push = (PushEffect, @escaping PushDispatch) -> Void
    
    typealias UpdateDispatch = (UpdateEvent) -> Void
    typealias Update = (UpdateEffect, @escaping UpdateDispatch) -> Void
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = PushUpdateFlowEvent<PushEvent, UpdateEvent>
    typealias Effect = PushUpdateFlowEffect<PushEffect, UpdateEffect>
}
