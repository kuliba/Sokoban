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
        paymentsTransfersFlag: PaymentsTransfersFlag,
        utilitiesPaymentsFlag: UtilitiesPaymentsFlag,
        model: Model,
        httpClient: HTTPClient,
        log: @escaping Log,
        scheduler: AnySchedulerOf<DispatchQueue>
    ) -> TemplatesListFlowModelComposer {
        
        let anywayTransactionViewModelComposer = AnywayTransactionViewModelComposer(
            flag: utilitiesPaymentsFlag.optionOrStub,
            model: model,
            httpClient: httpClient,
            log: log,
            scheduler: scheduler
        )
        let anywayFlowComposer = AnywayFlowComposer(
            makeAnywayTransactionViewModel: anywayTransactionViewModelComposer.compose(transaction:),
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
        
        let microServicesComposer = TemplatesListFlowEffectHandlerMicroServicesComposer<PaymentsViewModel, AnywayFlowModel>(
            initiatePayment: { template, completion in
                
                initiatePaymentFromTemplate(template) {
                    
                    switch $0 {
                    case let .failure(serviceFailure):
                        completion(.failure(serviceFailure))
                        
                    case let .success(transaction):
                        completion(.success(anywayFlowComposer.compose(transaction: transaction)))
                    }
                }
            },
            makeLegacyPayment: { payload in
                
                let (template, close) = payload
                
                return PaymentsViewModel(
                    source: .template(template.id),
                    model: model,
                    closeAction: close
                )
            },
            paymentsTransfersFlag: paymentsTransfersFlag,
            utilitiesPaymentsFlag: utilitiesPaymentsFlag
        )
        
        return .init(
            makeAnywayFlowModel: anywayFlowComposer.compose,
            model: model,
            microServices: microServicesComposer.compose(),
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
