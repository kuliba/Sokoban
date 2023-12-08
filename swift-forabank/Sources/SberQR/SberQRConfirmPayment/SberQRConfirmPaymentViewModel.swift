//
//  SberQRConfirmPaymentViewModel.swift
//
//
//  Created by Igor Malyarov on 08.12.2023.
//

import Combine
import CombineSchedulers
import Foundation

public final class SberQRConfirmPaymentViewModel: ObservableObject {
    
    public typealias State = SberQRConfirmPaymentState
    public typealias Event = SberQRConfirmPaymentEvent
    public typealias Reduce = (State, Event) -> State
    
    @Published public private(set) var state: State
    
    private let reduce: Reduce
    private let stateSubject = PassthroughSubject<State, Never>()
    
    public init(
        initialState: State,
        reduce: @escaping Reduce,
        scheduler: AnySchedulerOfDispatchQueue = .makeMain()
    ) {
        self.state = initialState
        self.reduce = reduce
        
        stateSubject
            .removeDuplicates()
            .receive(on: scheduler)
            .assign(to: &$state)
    }
}

public extension SberQRConfirmPaymentViewModel {
    
    func event(_ event: Event) {
        
        stateSubject.send(reduce(state, event))
    }
}
