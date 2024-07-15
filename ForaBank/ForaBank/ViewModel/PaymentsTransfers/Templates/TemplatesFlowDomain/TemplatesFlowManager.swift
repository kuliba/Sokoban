//
//  TemplatesFlowManager.swift
//  ForaBank
//
//  Created by Igor Malyarov on 04.07.2024.
//

struct TemplatesFlowManager {
    
    let reduce: Reduce
    let handleEffect: HandleEffect
}

extension TemplatesFlowManager {
    
    typealias Reduce = (State, Event) -> (State, Effect?)
    
    typealias Dispatch = (Event) -> Void
    typealias HandleEffect = (Effect, @escaping Dispatch) -> Void
    
    typealias State = TemplatesFlowState
    typealias Event = TemplatesFlowEvent
    typealias Effect = TemplatesFlowEffect
}
