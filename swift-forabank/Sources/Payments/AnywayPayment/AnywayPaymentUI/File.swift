//
//  File.swift
//
//
//  Created by Igor Malyarov on 22.04.2024.
//

import ForaTools
import Foundation
import SwiftUI

private struct LastPayment: Equatable {}
private struct Operator: Equatable {}
private struct UtilityService: Equatable {}

private typealias State = Stack<Destination>
    
private enum Destination: Equatable {
    
    case utilityPayment(UtilityPayment)
}

private extension Destination {
    
    typealias UtilityPayment = Result<UtilityPaymentPayload, UtilityPaymentFailure>
    
    struct UtilityPaymentFailure: Error, Equatable {}
    
    struct UtilityPaymentPayload: Equatable {
        
        let lastPayments: [LastPayment]
        let operators: [Operator] // non-empty
    }
}

private enum Event: Equatable {
    
    case loaded(Loaded)
    case utilityServicePaymentButtonTapped
    case utilityServicePicker(UtilityServicePickerEvent)
}

private struct PaymentsTransfersFactory<UtilityServicePicker>
where UtilityServicePicker: View {
    
    let makeUtilityServicePicker: MakeUtilityServicePicker
}

extension PaymentsTransfersFactory {
    
    typealias UtilityPaymentPayload = Destination.UtilityPaymentPayload
    typealias MakeUtilityServicePicker = (UtilityPaymentPayload, @escaping (UtilityServicePickerEvent) -> Void) -> UtilityServicePicker
}

private enum UtilityServicePickerEvent: Equatable {
    
    case addCompany
    case payByInstruction
    case select(Select)
}

extension UtilityServicePickerEvent {
    
    enum Select: Equatable {
        
        case lastPayment(LastPayment)
        case service(UtilityService, Operator)
    }
}

extension Event {
    
    typealias Loaded = Result<LoadResponse, LoadFailure>
    
    struct LoadFailure: Error, Equatable {}
    
    struct LoadResponse: Equatable {
        
        let lastPayments: [LastPayment]
        let operators: [Operator] // non-empty
    }
}

private enum Effect: Equatable {
    
    case initiateUtilityPayment(UtilityPaymentPayload)
    case initiateUtilityPaymentSelection
}

extension Effect {
    
    enum UtilityPaymentPayload: Equatable {
        
        case lastPayment(LastPayment)
        case service(UtilityService, Operator)
    }
}

private final class Reducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case let .loaded(loaded):
            (state, effect) = reduce(state, loaded)
            
        case .utilityServicePaymentButtonTapped:
            effect = .initiateUtilityPaymentSelection
            
        case let .utilityServicePicker(event):
            (state, effect) = reduce(state, event)
        }
        
        return (state, effect)
    }
}

private extension Reducer {
    
    func reduce(
        _ state: State,
        _ event: Event.Loaded
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case .failure:
            state.push(.utilityPayment(.failure(.init())))
            
        case let .success(response):
            state.push(.utilityPayment(.success(.init(
                lastPayments: response.lastPayments,
                operators: response.operators
            ))))
        }
        
        return (state, effect)
    }
    
    func reduce(
        _ state: State,
        _ event: UtilityServicePickerEvent
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case .addCompany:
            fatalError("can't change a global state from the local scope")
            
        case .payByInstruction:
            fatalError("need to push new destination to state stack")
            
        case let .select(select):
            (state, effect) = reduce(state, select)
        }
        
        return (state, effect)
    }
    
    private func reduce(
        _ state: State,
        _ event: UtilityServicePickerEvent.Select
    ) -> (State, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case let .lastPayment(lastPayment):
            effect = .initiateUtilityPayment(.lastPayment(lastPayment))
            
        case let .service(service, `operator`):
            effect = .initiateUtilityPayment(.service(service, `operator`))
        }
        
        return (state, effect)
    }
}

private final class EffectHandler {
    
    private let load: Load
    private let startUtilityPayment: StartUtilityPayment
    
    init(
        load: @escaping Load,
        startUtilityPayment: @escaping StartUtilityPayment
    ) {
        self.load = load
        self.startUtilityPayment = startUtilityPayment
    }
}

extension EffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case let .initiateUtilityPayment(payload):
            initiateUtilityPayment(payload, dispatch)
            
        case .initiateUtilityPaymentSelection:
            initiate(dispatch)
        }
    }
}

extension EffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias LoadResponse = Event.LoadResponse
    typealias LoadResult = Result<LoadResponse, Error>
    typealias LoadCompletion = (LoadResult) -> Void
    typealias Load = (@escaping LoadCompletion) -> Void
    
    typealias StartUtilityPaymentPayload = Effect.UtilityPaymentPayload
    typealias StartUtilityPaymentResult = Result<Void, Error>
    typealias StartUtilityPaymentCompletion = (StartUtilityPaymentResult) -> Void
    typealias StartUtilityPayment = (StartUtilityPaymentPayload, @escaping StartUtilityPaymentCompletion) -> Void
}

private extension EffectHandler {
    
    func initiate(
        _ dispatch: @escaping Dispatch
    ) {
        load { result in
            
            switch result {
            case .failure:
                dispatch(.loaded(.failure(.init())))
                
            case let .success(response):
                if response.operators.isEmpty {
                    dispatch(.loaded(.failure(.init())))
                } else {
                    dispatch(.loaded(.success(response)))
                }
            }
        }
    }
    
    func initiateUtilityPayment(
        _ payload: Effect.UtilityPaymentPayload,
        _ dispatch: @escaping Dispatch
    ) {
        startUtilityPayment(payload) { result in
            
        }
    }
}


private func utilityServicePaymentFlow(
    event: (Event) -> Void
) {
    
    event(.utilityServicePaymentButtonTapped)
}
