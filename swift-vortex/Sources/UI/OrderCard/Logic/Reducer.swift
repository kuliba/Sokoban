//
//  Reducer.swift
//
//
//  Created by Дмитрий Савушкин on 08.02.2025.
//

import Foundation

public final class Reducer<Confirmation> {
    
    private let otpWitness: OTPWitness
    public typealias OTPWitness = (Confirmation) -> (String) -> Void
    
    public init(
        otpWitness: @escaping OTPWitness
    ) {
        self.otpWitness = otpWitness
    }
}

public extension Reducer {
    
    func reduce(
        _ state: State<Confirmation>,
        _ event: Event<Confirmation>
    ) -> (State<Confirmation>, Effect?) {
        
        var state = state
        var effect: Effect?
        
        switch event {
        case .continue:
            reduceContinue(&state, &effect)
            
        case .dismissInformer:
            reduceDismissInformer(&state, &effect)
            
        case .load:
            switch state.loadableForm {
            case .loading:
                break // already loading
                
            case .loaded:
                state.loadableForm = .loading(state.loadableForm.state)
                effect = .load
            }
            
        case let .loadConfirmation(confirmation):
            state.loadableForm.state?.confirmation = .loaded(confirmation)
            
        case let .loaded(result):
            state.loadableForm = .loaded(result)
            
        case let .setMessages(isOn):
            if var loaded = state.loadableForm.state {
                state.loadableForm.state?.messages.isOn = isOn
            }
            
        case let .orderCardResult(orderCardResult):
            reduceOrderCard(&state, &effect, with: orderCardResult)
            
        case let .otp(otp):
            if !state.loadableForm.isLoading && state.hasConfirmation {
                state.loadableForm.state?.otp = otp
            }
            
        case let .setConsent(consent):
            if !state.loadableForm.isLoading && state.hasConfirmation {
                state.form?.consent = consent
            }
        }
        
        return (state, effect)
    }
}

private extension Reducer {
    
    func reduceContinue(
        _ state: inout State<Confirmation>,
        _ effect: inout Effect?
    ) {
        guard let form = state.loadableForm.state else { return }
        
        switch form.confirmation {
        case .loaded(nil):
            state.loadableForm = .loading(form)
            effect = .loadConfirmation
            
        case .loaded(.success):
            if let payload = state.payload {
                
                state.loadableForm = .loading(form)
                effect = .orderCard(payload)
            }
            
        case .loading:
            break // already loading
        
        case .loaded(.failure):
            break
        }
    }
    
    func reduceDismissInformer(
        _ state: inout State<Confirmation>,
        _ effect: inout Effect?
    ) {
        // reset form informer
        if case let .loaded(.failure(failure)) = state.loadableForm,
           case .informer = failure.type {
            
            state.loadableForm = .loaded(nil)
        }
        
        // reset confirmation informer
        if case let .loaded(.failure(failure)) = state.loadableForm.state?.confirmation,
           case .informer = failure.type {
            
            state.form?.confirmation = .loaded(nil)
        }
    }
    
    func reduceOrderCard(
        _ state: inout State<Confirmation>,
        _ effect: inout Effect?,
        with orderCardResult: Event.OrderCardResult
    ) {
        switch orderCardResult {
        case let .failure(loadFailure):
            let notifyOTP = state.loadableForm.state?.confirmation.state.map(otpWitness)
            notifyOTP?(loadFailure.message)
            
        case let .success(orderCardResponse):
            state.loadableForm.state?.orderCardResponse = orderCardResponse
        }
    }
}
