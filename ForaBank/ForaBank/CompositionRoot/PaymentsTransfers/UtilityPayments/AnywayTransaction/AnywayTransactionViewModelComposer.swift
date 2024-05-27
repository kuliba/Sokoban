//
//  AnywayTransactionViewModelComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 23.05.2024.
//

import AnywayPaymentCore
import AnywayPaymentDomain
import Foundation

final class AnywayTransactionViewModelComposer {
    
    private let flag: StubbedFeatureFlag.Option
    private let httpClient: HTTPClient
    private let log: Log
    
    init(
        flag: StubbedFeatureFlag.Option,
        httpClient: HTTPClient,
        log: @escaping Log
    ) {
        self.flag = flag
        self.httpClient = httpClient
        self.log = log
    }
}

extension AnywayTransactionViewModelComposer {
    
    func compose(
        initialState: AnywayTransactionState
    ) -> ViewModel {
        
        switch flag {
        case .live: return live(initialState)
        case .stub: return stub(initialState)
        }
    }
}

extension AnywayTransactionViewModelComposer {
    
    typealias Log = (String, StaticString, UInt) -> Void
    typealias ViewModel = AnywayTransactionViewModel
}

private extension AnywayTransactionViewModelComposer {
    
    func live(
        _ initialState: AnywayTransactionState
    ) -> ViewModel {
        
        let nanoServicesComposer = AnywayTransactionEffectHandlerNanoServicesComposer(
            httpClient: httpClient,
            log: log
        )
        let microServicesComposer = AnywayTransactionEffectHandlerMicroServicesComposer(
            nanoServices: nanoServicesComposer.compose()
        )
        let microServices = microServicesComposer.compose()
        
        return makeViewModel(initialState, microServices)
    }
    
    func stub(
        _ initialState: AnywayTransactionState
    ) -> ViewModel {
        
        let microServices = AnywayTransactionEffectHandlerMicroServices.stubbed(
            with: .init(
                initiatePayment: .success(.preview),
                makePayment: .init(
                    status: .completed,
                    info: .details("Operation Detail")
                ),
                processPayment: .success(.preview))
        )
        
        return makeViewModel(initialState, microServices)
    }
    
    func makeViewModel(
        _ initialState: AnywayTransactionState,
        _ microServices: MicroServices
    ) -> ViewModel {
        
        let effectHandler = EffectHandler(microServices: microServices)
        
        let composer = AnywayPaymentTransactionReducerComposer<Report>()
        let reducer = composer.compose()
        
        return .init(
            initialState: initialState,
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:)
        )
    }
    
    typealias MicroServices = AnywayTransactionEffectHandlerMicroServices
    
    typealias Reducer = TransactionReducer<Report, AnywayPaymentContext, AnywayPaymentEvent, AnywayPaymentEffect, AnywayPaymentDigest, AnywayPaymentUpdate>
    typealias EffectHandler = TransactionEffectHandler<Report, AnywayPaymentDigest, AnywayPaymentEffect, AnywayPaymentEvent, AnywayPaymentUpdate>
}

private extension AnywayTransactionEffectHandlerMicroServices {
    
    static func stubbed(
        with stub: Stub
    ) -> Self {
        
        return .init(
            initiatePayment: _initiatePayment(with: stub.initiatePayment),
            makePayment: _makePayment(with: stub.makePayment),
            paymentEffectHandle: { _,_ in }, // AnywayPaymentEffect is empty
            processPayment: _processPayment(with: stub.processPayment)
        )
    }
    
    struct Stub {
        
        let initiatePayment: ProcessResult
        let makePayment: Report?
        let processPayment: ProcessResult
    }
    
    private static func _initiatePayment(
        with stub: ProcessResult
    ) -> InitiatePayment {
        
        return { _, completion in
            
            DispatchQueue.main.delay(for: .seconds(1)) { completion(stub) }
        }
    }
    
    private static func _makePayment(
        with stub: Report?
    ) -> MakePayment {
        
        return { _, completion in
            
            DispatchQueue.main.delay(for: .seconds(1)) { completion(stub) }
        }
    }
    
    private static func _processPayment(
        with stub: ProcessResult
    ) -> ProcessPayment {
        
        return { _, completion in
            
            DispatchQueue.main.delay(for: .seconds(1)) { completion(stub) }
        }
    }
}

extension AnywayPaymentUpdate {
    
    static let preview: Self = .init(
        details: .preview,
        fields: [],
        parameters: []
    )
}

private extension AnywayPaymentUpdate.Details {
    
    static let preview: Self = .init(
        amounts: .preview,
        control: .preview,
        info: .preview
    )
}

private extension AnywayPaymentUpdate.Details.Amounts {
    
    static let preview: Self = .init(
        amount: nil,
        creditAmount: nil,
        currencyAmount: nil,
        currencyPayee: nil,
        currencyPayer: nil,
        currencyRate: nil,
        debitAmount: nil,
        fee: nil
    )
}

private extension AnywayPaymentUpdate.Details.Control {
    
    static let preview: Self = .init(
        isFinalStep: false,
        isFraudSuspected: false,
        needMake: false,
        needOTP: false,
        needSum: false
    )
}

private extension AnywayPaymentUpdate.Details.Info {
    
    static let preview: Self = .init(
        documentStatus: nil,
        infoMessage: nil,
        payeeName: nil,
        paymentOperationDetailID: nil,
        printFormType: nil
    )
}
