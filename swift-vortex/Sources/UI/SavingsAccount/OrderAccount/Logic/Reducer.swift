//
//  Reducer.swift
//
//
//  Created by Andryusina Nataly on 20.02.2025.
//

import Foundation
import LoadableState
import PaymentComponents

public final class Reducer<Confirmation> {
    
    private let otpWitness: OTPWitness
    private let productSelectReduce: ProductSelectReduce
    public typealias OTPWitness = (Confirmation) -> (String) -> Void

    public init(
        otpWitness: @escaping OTPWitness,
        productSelectReduce: @escaping ProductSelectReduce
    ) {
        self.otpWitness = otpWitness
        self.productSelectReduce = productSelectReduce
    }
}

public extension Reducer {
    
    func reduce(
        _ state: State,
        _ event: Event
    ) -> (State, Effect?) {
        
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
                state.loadableForm.state?.topUp.isOn = isOn
                state.loadableForm.state?.topUp.isShowFooter = isOn
            }
            
        case let .orderAccountResult(orderAccountResult):
            reduceOrderAccount(&state, &effect, with: orderAccountResult)
            
        case let .otp(otp):
            if !state.loadableForm.isLoading && state.hasConfirmation {
                state.loadableForm.state?.otp = otp
            }
            
        case let .setConsent(consent):
            if !state.loadableForm.isLoading && state.hasConfirmation {
                state.form?.consent = consent
            }
        case let .productSelect(productSelectEvent):
            state.productSelect = productSelectReduce(state.productSelect, productSelectEvent)
            
            guard let form = state.form,
                  let balance = state.productSelect.selected?.balance,
                  let amountValue = form.amountValue
            else { break }
            
            let isValid: Bool = (form.consent && amountValue > 0 && balance >= amountValue )

            state.form?.amount = .init(title: form.amount.title, value: amountValue, button: .init(title: form.amount.button.title, isEnabled: isValid))

        case let .amount(amountEvent):
            switch amountEvent {
            case let .edit(decimal):
                guard let form = state.form,
                      form.topUp.isOn,
                      let balance = state.productSelect.selected?.balance
                else { break }

                let isValid: Bool = (form.consent &&  decimal > 0 && balance >= decimal)
                
                state.form?.amount = .init(title: form.amount.title, value: decimal, button: .init(title: form.amount.button.title, isEnabled: isValid))
                
            case .pay:
                let isValid = true // check balance!!! + validate

                guard isValid else { break }
                state.form?.topUp.isShowFooter = false
                reduceContinue(&state, &effect)
            }
        }
        
        return (state, effect)
    }
}

private extension Reducer {
    
    func reduceContinue(
        _ state: inout State,
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
                effect = .orderAccount(payload)
            }
            
        case .loading:
            break // already loading
        
        case .loaded(.failure):
            break // cannot continue on failure
        }
    }
    
    func reduceDismissInformer(
        _ state: inout State,
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
    
    func reduceOrderAccount(
        _ state: inout State,
        _ effect: inout Effect?,
        with orderAccountResult: ProductEvent.OrderAccountResult
    ) {

        switch (state.loadableForm, orderAccountResult) {
            
        case (.loaded, _):
            break // cannot receive orderAccountResult in loaded state
            
        case (.loading(nil), _):
            break // cannot receive orderAccountResult in empty loading state
            
        case (var .loading(.some(form)), let .failure(loadFailure)):
            
            switch loadFailure.type {
            case .otp:
                let notifyOTP = form.confirmation.state.map(otpWitness)
                notifyOTP?(loadFailure.message)
                
            case .informer:
                break
                
            case .alert:
                form.orderAccountResponse = .reject
            }
            state.loadableForm = .loaded(.success(form))
            
        case(var.loading(.some(form)), let .success(orderAccountResponse)):
            form.orderAccountResponse = .init(orderAccountResponse, state.productSelect.selected)
            state.loadableForm = .loaded(.success(form))
        }
    }
}

public extension Reducer {
    
    typealias State = ProductState<Confirmation>
    typealias Event = ProductEvent<Confirmation>
    typealias Effect = ProductEffect
    
    typealias ProductSelectReduce = (ProductSelect, ProductSelectEvent) -> ProductSelect
}

private extension Form {
    
    var payload: ProductEffect.LoadConfirmationPayload {
        
        .init(condition: constants.links.conditions, tariff: constants.links.tariff)
    }
}

private extension OrderAccountResponse {
    
    init(
        _ data: OrderAccountResponse,
        _ product: ProductSelect.Product?
    ) {
        
        self.init(
            accountId: data.accountId,
            accountNumber: data.accountNumber,
            paymentOperationDetailId: data.paymentOperationDetailId,
            product: product,
            openData: data.openData,
            status: data.status
        )
    }
}

private extension OrderAccountResponse {
    
    static let reject: Self = .init(.init(accountId: nil, accountNumber: nil, paymentOperationDetailId: nil, product: nil, openData: nil, status: .rejected), nil)
}
