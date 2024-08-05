//
//  AsyncPickerEffectHandlerMicroServicesComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 04.08.2024.
//

import ForaTools
import Foundation

final class AsyncPickerEffectHandlerMicroServicesComposer {
    
    // TODO: get rid of this dependency - used for its `makeStartPaymentResult`
    private let composer: Composer
    private let nanoServices: NanoServices
    
    init(
        composer: Composer,
        nanoServices: NanoServices
    ) {
        self.composer = composer
        self.nanoServices = nanoServices
    }
    
    typealias Composer = UtilityPrepaymentFlowMicroServicesComposer
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
        // TODO: needs simplification and decoupling from `nanoServices.startAnywayPayment` which is much more complex than is needed in this case
        self.nanoServices.startAnywayPayment(
            .service(service, for: payload.provider.operator)
        ) {
            // TODO: get rid of this dependency
            let result = self.composer.makeStartPaymentResult(from: $0, service, payload.provider.operator)
            
            switch result {
            case let .failure(.serviceFailure(.serverError(errorMessage))):
                completion(.failure(.serverError(errorMessage)))
                
            case let .success(.startPayment(transaction)):
                completion(.success(transaction))
                
            default:
                completion(.failure(.connectivityError))
            }
        }
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
