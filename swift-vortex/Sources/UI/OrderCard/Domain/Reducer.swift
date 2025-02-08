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
            state.isLoading = true
            effect = .load
            
        case let .loadConfirmation(confirmation):
            state.isLoading = false
            state.form?.confirmation = confirmation
            
        case let .loaded(result):
            state.isLoading = false
            state.formResult = result
            
        case let .setMessages(isOn):
            if !state.isLoading {
                state.form?.messages.isOn = isOn
            }
            
        case let .orderCardResult(orderCardResult):
            // TODO: extract to helper
            state.isLoading = false
            
            switch orderCardResult {
            case let .failure(loadFailure):
//                let notifyOTP = state.form?.confirmation?.success.flatMap(otpWitness)
//                notifyOTP?(loadFailure.message)
                break
                //TODO: Fix with associated type
            case let .success(orderCardResponse):
                state.form?.orderCardResponse = orderCardResponse
            }
            
        case let .otp(otp):
            if !state.isLoading && state.hasConfirmation {
                state.form?.otp = otp
            }
            
        case let .setConsent(consent):
            if !state.isLoading && state.hasConfirmation {
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
        guard let form = state.form else { return }
        
        switch form.confirmation {
        case .none:
            state.isLoading = true
            effect = .loadConfirmation
            
        case .some:
            if let payload = state.payload {
                
                state.isLoading = true
                effect = .orderCard(payload)
            }
        }
    }
    
    func reduceDismissInformer(
        _ state: inout State<Confirmation>,
        _ effect: inout Effect?
    ) {
        if case let .failure(failure) = state.formResult,
           case .informer = failure.type {
            
            state.formResult = nil
        }
        
        if case let .failure(failure) = state.form?.confirmation,
           case .informer = failure.type {
            
            state.form?.confirmation = nil
        }
    }
}
