//
//  RootViewModelFactory+makeTemplatesComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 10.08.2024.
//

import CombineSchedulers
import Foundation

extension RootViewModelFactory {
    
    static func makeTemplatesComposer(
        utilitiesPaymentsFlag: UtilitiesPaymentsFlag,
        model: Model,
        httpClient: HTTPClient,
        log: @escaping Log,
        scheduler: AnySchedulerOf<DispatchQueue>
    ) -> TemplatesListFlowModelComposer {
        
        let anywayTransactionViewModelComposer = AnywayTransactionViewModelComposer(
            flag: utilitiesPaymentsFlag,
            model: model,
            httpClient: httpClient,
            log: log,
            scheduler: scheduler
        )
        let anywayFlowComposer = AnywayFlowComposer(
            composer: anywayTransactionViewModelComposer,
            model: model,
            scheduler: scheduler
        )
        let initiatePayment = NanoServices.initiateAnywayPayment(
            flag: utilitiesPaymentsFlag.optionOrStub,
            httpClient: httpClient,
            log: log,
            scheduler: scheduler
        )
        let composer = InitiateAnywayPaymentMicroServiceComposer(
            getOutlineProduct: { _ in model.outlineProduct() },
            processPayload: { payload, completion in
                
                initiatePayment(payload.outline.payload.puref) {
                    
                    switch $0 {
                    case let .failure(serviceFailure):
                        switch serviceFailure {
                        case .connectivityError:
                            completion(.failure(.connectivityError))
                            
                        case let .serverError(message):
                            completion(.failure(.serverError(message)))
                        }
                        
                    case let .success(response):
                        completion(.success(response))
                    }
                }
            }
        )
        let initiatePaymentMicroService = composer.compose()
        let initiatePaymentFromTemplate = { template, completion in
            
            initiatePaymentMicroService.initiatePayment(.template(template), completion)
        }
        
        return .init(
            composer: anywayFlowComposer,
            model: model,
            nanoServices: .init(
                initiatePayment: initiatePaymentFromTemplate
            ),
            utilitiesPaymentsFlag: utilitiesPaymentsFlag,
            scheduler: scheduler
        )
    }
}

private extension PaymentTemplateData {
    
    var puref: String? {
        
        let asTransferAnywayData = parameterList
            .compactMap { $0 as? TransferAnywayData }
        
        return asTransferAnywayData.compactMap(\.puref).first
    }
}
