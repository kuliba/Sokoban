//
//  SberQRConfirmPaymentStateReducer.swift
//
//
//  Created by Igor Malyarov on 07.12.2023.
//

public final class SberQRConfirmPaymentStateReducer {
    
    public typealias State = SberQRConfirmPaymentState
    public typealias Event = SberQRConfirmPaymentEvent
    
    public typealias EditableState = EditableAmount<GetSberQRDataResponse.Parameter.Info>
    public typealias EditableEvent = Event.EditableAmount
    public typealias EditableReduce = (EditableState, EditableEvent) -> EditableState
    
    public typealias FixedState = FixedAmount<GetSberQRDataResponse.Parameter.Info>
    public typealias FixedEvent = Event.FixedAmount
    public typealias FixedReduce = (FixedState, FixedEvent) -> FixedState
    
    public typealias Pay = (State) -> Void

    private let editableReduce: EditableReduce
    private let fixedReduce: FixedReduce
    private let pay: Pay

    public init(
        editableReduce: @escaping EditableReduce,
        fixedReduce: @escaping FixedReduce,
        pay: @escaping Pay
    ) {
        self.editableReduce = editableReduce
        self.fixedReduce = fixedReduce
        self.pay = pay
   }
}

public extension SberQRConfirmPaymentStateReducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> State {
        
        var state = state
        
        switch (state.confirm, state.isInflight, event) {
        case let (.editableAmount(editableState), _, .editable(editableEvent)):
            state.confirm = .editableAmount(editableReduce(editableState, editableEvent))
            
        case let (.fixedAmount(fixedState), _, .fixed(fixedEvent)):
            state.confirm = .fixedAmount(fixedReduce(fixedState, fixedEvent))
        
        case (_, false, .pay):
            state.isInflight = true
            pay(state)
            
        default:
            break
        }
        
        return state
    }
}
