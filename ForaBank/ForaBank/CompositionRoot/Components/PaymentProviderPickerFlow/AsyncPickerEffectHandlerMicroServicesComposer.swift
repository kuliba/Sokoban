//
//  AsyncPickerEffectHandlerMicroServicesComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 04.08.2024.
//

import AnywayPaymentCore
import AnywayPaymentDomain
import ForaTools
import Foundation
import RemoteServices

final class AsyncPickerEffectHandlerMicroServicesComposer {
    
    private let nanoServices: NanoServices
    
    init(
        nanoServices: NanoServices
    ) {
        self.nanoServices = nanoServices
    }
    
    typealias NanoServices = UtilityPaymentNanoServices
}

extension AsyncPickerEffectHandlerMicroServicesComposer {
    
    func compose() -> MicroServices {
        
        return .init(load: load(_:_:), select: select(_:_:_:))
    }
    
    typealias MicroServices = AsyncPickerEffectHandlerMicroServices<PaymentProviderServicePickerPayload, UtilityService, PaymentProviderServicePickerResult>
}

private extension AsyncPickerEffectHandlerMicroServicesComposer {
    
    func load(
        _ payload: PaymentProviderServicePickerPayload,
        _ completion: @escaping ([UtilityService]) -> Void
    ) {
        nanoServices.getServicesFor(payload.provider.operator) {
            
            completion((try? $0.get()) ?? [])
            _ = self.nanoServices
        }
    }
    
    func select(
        _ service: UtilityService,
        _ payload: PaymentProviderServicePickerPayload,
        _ completion: @escaping (PaymentProviderServicePickerResult) -> Void
    ) {
        self.nanoServices.startAnywayPayment(
            .service(service, for: payload.provider.operator)
        ) {
            switch StartPaymentResult(result: $0) {
            case let .failure(failure):
                completion(.failure(failure))
                
            case let .success(response):
                
                let context = AnywayPaymentContext(
                    response: response,
                    service: service,
                    payload: payload
                )
                
                // TODO: replace with injected dependency
                let validator = AnywayPaymentContextValidator()
                
                let transaction = AnywayTransactionState.Transaction(
                    context: context,
                    isValid: validator.validate(context) == nil
                )
                
                completion(.success(transaction))
            }
        }
    }
}

private typealias AnywayResponse = RemoteServices.ResponseMapper.CreateAnywayTransferResponse

private typealias StartPaymentResult = Result<AnywayResponse, ServiceFailureAlert.ServiceFailure>

private extension StartPaymentResult {
    
    init(result: UtilityPaymentNanoServices.StartAnywayPaymentResult) {
        
        switch result {
        case let .failure(failure):
            self.init(failure: failure)
            
        case let .success(success):
            self.init(success: success)
        }
    }
    
    init(failure: UtilityPaymentNanoServices.StartAnywayPaymentFailure) {
        
        switch failure {
        case .operatorFailure:
            self = .failure(.connectivityError)
            
        case .serviceFailure(.connectivityError):
            self = .failure(.connectivityError)
            
        case let .serviceFailure(.serverError(message)):
            self = .failure(.serverError(message))
        }
    }
    
    init(success: UtilityPaymentNanoServices.StartAnywayPaymentSuccess) {
        
        switch success {
        case .services:
            self = .failure(.connectivityError)
            
        case let .startPayment(startPaymentResponse):
            self = .success(startPaymentResponse)
        }
    }
}

private extension AnywayPaymentContext {
    
    init(
        response: AnywayResponse,
        service: UtilityService,
        payload: PaymentProviderServicePickerPayload
    ) {
        let outline = AnywayPaymentOutline(
            service: service,
            payload: payload
        )
        self.init(response: response, outline: outline)
    }
    
    init(
        response: AnywayResponse,
        outline: AnywayPaymentOutline
    ) {
        let initialElements: [AnywayElement] = []
        let initialPayment = AnywayPaymentDomain.AnywayPayment(
            amount: outline.amount,
            elements: initialElements,
            footer: .continue,
            isFinalStep: false
        )
        
        self.init(
            initial: initialPayment,
            payment: initialPayment.updating(with: response, outline: outline),
            staged: .init(),
            outline: outline,
            shouldRestart: false
        )
    }
}

private extension AnywayPaymentDomain.AnywayPayment {
    
    func updating(
        with response: AnywayResponse,
        outline: AnywayPaymentOutline
    ) -> Self {
        
        if let update = AnywayPaymentUpdate(response) {
            return self.update(with: update, and: outline)
        } else {
            return self
        }
    }
}

private extension AnywayPaymentOutline {
    
    init(
        service: UtilityService,
        payload: PaymentProviderServicePickerPayload
    ) {
        fatalError()
//        self.init(
//            amount: payload.qrCode.,
//            product: <#T##Product?#>,
//            fields: <#T##Fields#>,
//            payload: <#T##Payload#>
//        )
    }
}

private extension SegmentedProvider {
    
    var `operator`: UtilityPaymentOperator {
        
        return .init(
            id: origin.id,
            title: origin.title,
            subtitle: origin.inn,
            icon: origin.icon
        )
    }
}
