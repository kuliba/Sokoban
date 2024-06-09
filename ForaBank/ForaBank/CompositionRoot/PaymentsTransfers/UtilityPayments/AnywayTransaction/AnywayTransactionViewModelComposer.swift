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
    
    private let flag: Flag
    private let httpClient: HTTPClient
    private let log: Log
    
    init(
        flag: Flag,
        httpClient: HTTPClient,
        log: @escaping Log
    ) {
        self.flag = flag
        self.httpClient = httpClient
        self.log = log
    }
    
    typealias Flag = StubbedFeatureFlag.Option
    typealias Log = (LoggerAgentLevel, LoggerAgentCategory, String, StaticString, UInt) -> Void
}

extension AnywayTransactionViewModelComposer {
    
    func compose(
        initialState: AnywayTransactionState,
        observe: @escaping Observe
    ) -> ViewModel {
        
        let nanoServicesComposer = AnywayTransactionEffectHandlerNanoServicesComposer(
            flag: flag,
            httpClient: httpClient,
            log: log
        )
        let microServicesComposer = AnywayTransactionEffectHandlerMicroServicesComposer(
            nanoServices: nanoServicesComposer.compose()
        )
        let microServices = microServicesComposer.compose()
        
        return makeViewModel(initialState, microServices, observe)
    }
    
    typealias Observe = (AnywayTransactionState, AnywayTransactionState) -> Void
    typealias ViewModel = AnywayTransactionViewModel
}

private extension AnywayTransactionViewModelComposer {
    
    func makeViewModel(
        _ initialState: AnywayTransactionState,
        _ microServices: MicroServices,
        _ observe: @escaping Observe
    ) -> ViewModel {
        
        let effectHandler = EffectHandler(microServices: microServices)
        
        let composer = AnywayPaymentTransactionReducerComposer<AnywayTransactionReport>()
        let reducer = composer.compose()
        
        return .init(
            initialState: initialState,
            reduce: reducer.reduce(_:_:),
            handleEffect: effectHandler.handleEffect(_:_:),
            observe: observe
        )
    }
    
    typealias MicroServices = AnywayTransactionEffectHandlerMicroServices
    
    typealias EffectHandler = TransactionEffectHandler<AnywayTransactionReport, AnywayPaymentDigest, AnywayPaymentEffect, AnywayPaymentEvent, AnywayPaymentUpdate>
}
