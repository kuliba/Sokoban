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
            if state.loadableForm.state != nil {
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
            state.loadableForm.state?.confirmation = .loading(nil)
            effect = .loadConfirmation(form.payload)
            
        case .loaded(.success):
            if let payload = state.payload {
                
                state.loadableForm = .loading(form)
                effect = .orderCard(payload)
            }
            
        case .loading:
            break // already loading
        
        case .loaded(.failure):
            break // cannot continue on failure
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
        switch (state.loadableForm, orderCardResult) {
        case (.loaded, _):
            break // cannot receive orderCardResult in loaded state
            
        case (.loading(nil), _):
            break // cannot receive orderCardResult in empty loading state
            
        case let (.loading(.some(form)), .failure(loadFailure)):
            let notifyOTP = form.confirmation.state.map(otpWitness)
            notifyOTP?(loadFailure.message)
            state.loadableForm = .loaded(.success(form))
            
        case (var.loading(.some(form)), let .success(orderCardResponse)):
            form.orderCardResponse = orderCardResponse
            state.loadableForm = .loaded(.success(form))
        }
    }
}

private extension Form {
    
    var payload: Effect.LoadConfirmationPayload {
        
        .init(condition: conditions, tariff: tariffs)
    }
}
