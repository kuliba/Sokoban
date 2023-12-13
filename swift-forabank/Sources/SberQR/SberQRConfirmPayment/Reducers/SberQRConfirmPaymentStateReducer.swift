//
//  SberQRConfirmPaymentStateReducer.swift
//
//
//  Created by Igor Malyarov on 07.12.2023.
//

public final class SberQRConfirmPaymentStateReducer {
    
    public typealias State = SberQRConfirmPaymentState
    public typealias Event = SberQRConfirmPaymentEvent
    
    public typealias EditableState = State.EditableAmount
    public typealias EditableEvent = Event.EditableAmount
    public typealias EditableReduce = (EditableState, EditableEvent) -> EditableState
    
    public typealias FixedState = State.FixedAmount
    public typealias FixedEvent = Event.FixedAmount
    public typealias FixedReduce = (FixedState, FixedEvent) -> FixedState
    
    private let editableReduce: EditableReduce
    private let fixedReduce: FixedReduce
    
    public init(
        editableReduce: @escaping EditableReduce,
        fixedReduce: @escaping FixedReduce
    ) {
        self.editableReduce = editableReduce
        self.fixedReduce = fixedReduce
    }
}

public extension SberQRConfirmPaymentStateReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> State {
        
        var newState = state
        
        switch (state, event) {
        case let (.editableAmount(state), .editable(event)):
            newState = .editableAmount(editableReduce(state, event))
            
        case let (.fixedAmount(state), .fixed(event)):
            newState = .fixedAmount(fixedReduce(state, event))
            
        default:
            break
        }
        
        return newState
    }
}
