//
//  RootViewModelFactory+makeC2BPayment.swift
//  Vortex
//
//  Created by Igor Malyarov on 13.02.2025.
//

import C2GCore
import Foundation
import PaymentComponents
import RemoteServices

extension RootViewModelFactory {
    
    @inlinable
    func makeC2BPayment(
        payload: C2GPaymentDomain.ContentPayload
    ) -> C2GPaymentDomain.Binder {
        
        composeBinder(
            content: makeC2BPaymentContent(payload: payload),
            delayProvider: delayProvider,
            getNavigation: getNavigation,
            selectWitnesses: .empty
        )
    }
    
    @inlinable
    func makeC2BPaymentContent(
        payload: C2GPaymentDomain.ContentPayload
    ) -> C2GPaymentDomain.Content {
        
        return .init(payload: payload, scheduler: schedulers.main)
    }
    
    @inlinable
    func delayProvider(
        navigation: C2GPaymentDomain.Navigation
    ) -> Delay {
        
        return .zero
    }
    
    @inlinable
    func getNavigation(
        select: C2GPaymentDomain.Select,
        notify: @escaping C2GPaymentDomain.Notify,
        completion: @escaping (C2GPaymentDomain.Navigation) -> Void
    ) {
        switch select {
        case let .pay(payload):
            createC2GPayment(payload, completion: completion)
        }
    }
    
    @inlinable
    func createC2GPayment(
        _ digest: C2GPaymentDomain.Select.Digest,
        completion: @escaping (C2GPaymentDomain.Navigation) -> Void
    ) {
        let payload = digest.payload
        
        guard !payload.uin.hasEasterEgg
        else { return createC2GPaymentEasterEggs(payload, completion: completion) }
        
        let service = onBackground(
            makeRequest: RequestFactory.createCreateC2GPaymentRequest,
            mapResponse: RemoteServices.ResponseMapper.mapCreateC2GPaymentResponse
        )
        
        service(payload) { [weak self] in
            
            guard let self else { return }
            
            completion($0.navigation(formattedAmount: formatAmount(value: $0.success?.amount)));
            _ = service
        }
    }
    
    private func formatAmount(
        value: Decimal?
    ) -> String? {
        
        guard let value = value?.doubleValue else { return nil }
        
        return model.amountFormatted(amount: value, currencyCode: "RUB", style: .normal)
    }

    // TODO: remove stub
    @inlinable
    func createC2GPaymentEasterEggs(
        _ payload: RemoteServices.RequestFactory.CreateC2GPaymentPayload,
        completion: @escaping (C2GPaymentDomain.Navigation) -> Void
    ) {
        schedulers.background.delay(for: .seconds(2)) {
            
            switch payload.uin {
            case "01234567890123456789":
                completion(.connectivityFailure)
                
            case "12345678901234567890":
                completion(.failure(.server("server error")))
                
            default:
                completion(.failure(.server("server error")))
            }
        }
    }
}

// MARK: - Helpers

private extension C2GPaymentDomain.Navigation {
    
    static let connectivityFailure: Self = .failure(.connectivityFailure)
}

private extension BackendFailure {
    
    static let connectivityFailure: Self = .connectivity("Возникла техническая ошибка.\nСвяжитесь с поддержкой банка для уточнения")
}

// TODO: remove with stub
private extension String {
    
    var hasEasterEgg: Bool {
        
        ["01234567890123456789", "12345678901234567890"].contains(self)
    }
}

// MARK: - Adapters

private extension Result
where Success == RemoteServices.ResponseMapper.CreateC2GPaymentResponse {
    
    func navigation(
        formattedAmount: String?
    ) -> C2GPaymentDomain.Navigation {
        
        switch self {
        case let .failure(failure as BackendFailure):
            return .failure(failure)
            
        case .failure:
            return .connectivityFailure
            
        case let .success(response):
            return response.result(formattedAmount: formattedAmount)
        }
    }
}

private extension RemoteServices.ResponseMapper.CreateC2GPaymentResponse {
    
    func result(
        formattedAmount: String?
    ) -> C2GPaymentDomain.Navigation {
        
        guard let status
        else { return .failure(.connectivityFailure) }
        
        return .success(success(formattedAmount: formattedAmount, status: status))
    }
    
    private var status: C2GPaymentDomain.Navigation.C2GPaymentComplete.Status? {
        
        switch documentStatus {
        case "COMPLETE":    return .completed
        case "REJECTED":    return .inflight
        case "IN_PROGRESS": return .rejected
        default:            return nil
        }
    }
    
    private func success(
        formattedAmount: String?,
        status: C2GPaymentDomain.Navigation.C2GPaymentComplete.Status
    ) -> C2GPaymentDomain.Navigation.C2GPaymentComplete {
        
        return .init(
            formattedAmount: formattedAmount,
            status: status,
            merchantName: merchantName,
            message: message,
            paymentOperationDetailID: paymentOperationDetailID,
            purpose: purpose
        )
    }
}

private extension C2GPaymentDigest {
    
    var payload: RemoteServices.RequestFactory.CreateC2GPaymentPayload {
        
        switch productID.type {
        case .account:
            return .init(accountID: productID.id, cardID: nil, uin: uin)
            
        case .card:
            return .init(accountID: nil, cardID: productID.id, uin: uin)
        }
    }
}

private extension C2GPaymentState
where Context == C2GPaymentDomain.Context {
    
    init(payload: C2GPaymentDomain.ContentPayload) {
        
        self.init(
            context: .init(term: .terms(url: payload.url)),
            productSelect: .init(selected: payload.selectedProduct),
            termsCheck: payload.termsCheck,
            uin: payload.uin
        )
    }
}

private extension AttributedString {
    
    static func terms(url: URL?) -> Self {
        
        var attributedString = AttributedString.turnSBPOnMessage
        attributedString.foregroundColor = .textPlaceholder
        attributedString.font = .textBodyMR14200()
        
        if let url, let terms = attributedString.range(of: String.termURLPlace) {
            
            attributedString[terms].link = url
            attributedString[terms].underlineStyle = .single
            attributedString[terms].foregroundColor = .textSecondary
        }
        
        return attributedString
    }
}

private extension AttributedString {
    
    static let turnSBPOnMessage: Self = .init("Включить переводы через СБП,\n\(String.termURLPlace)")
}

private extension String {
    
    static let termURLPlace = "принять условия обслуживания"
}

import CombineSchedulers

extension C2GPaymentViewModel
where State == C2GPaymentState<C2GPaymentDomain.Context>,
      Event == C2GPaymentEvent,
      Effect == C2GPaymentEffect {
    
    convenience init(
        payload: C2GPaymentDomain.ContentPayload,
        scheduler: AnySchedulerOf<DispatchQueue>
    ) {
        let initialState = C2GPaymentState(payload: payload)
        
        let productSelectReducer = ProductSelectReducer(
            getProducts: { payload.products }
        )
        let reducer = C2GPaymentDomain.ContentReducer(
            productSelectReduce: productSelectReducer.reduce
        )
        
        self.init(
            initialState: initialState,
            reduce: reducer.reduce,
            handleEffect: { _,_ in },
            scheduler: scheduler
        )
    }
}
