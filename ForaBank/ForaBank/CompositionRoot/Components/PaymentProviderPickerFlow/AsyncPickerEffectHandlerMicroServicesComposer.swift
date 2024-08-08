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
    
    private let composer: AnywayTransactionComposer
    private let model: Model
    private let nanoServices: NanoServices
    
    init(
        composer: AnywayTransactionComposer,
        model: Model,
        nanoServices: NanoServices
    ) {
        self.composer = composer
        self.model = model
        self.nanoServices = nanoServices
    }
    
    typealias NanoServices = UtilityPaymentNanoServices
}

extension AsyncPickerEffectHandlerMicroServicesComposer {
    
    func compose() -> MicroServices {
        
        return .init(load: load(_:_:), select: select(_:_:_:))
    }
    
    typealias MicroServices = AsyncPickerEffectHandlerMicroServices<PaymentProviderServicePickerPayload, ServicePickerItem, PaymentProviderServicePickerResult>
}

private extension AsyncPickerEffectHandlerMicroServicesComposer {
    
    func load(
        _ payload: PaymentProviderServicePickerPayload,
        _ completion: @escaping ([ServicePickerItem]) -> Void
    ) {
        nanoServices.getServicesFor(payload.provider.operator) {
            
            let services = (try? $0.get()) ?? []
            completion(services.map {
                
                return .init(service: $0, isOneOf: services.count > 1)
            })
            _ = self.nanoServices
        }
    }
    
    func select(
        _ item: ServicePickerItem,
        _ payload: PaymentProviderServicePickerPayload,
        _ completion: @escaping (PaymentProviderServicePickerResult) -> Void
    ) {
        self.nanoServices.startAnywayPayment(
            .service(item.service, for: payload.provider.operator)
        ) {
            switch StartPaymentResult(result: $0) {
            case let .failure(failure):
                completion(.failure(failure))
                
            case let .success(response):
                guard let transaction = self.composer.makeTransaction(from: response, item: item, payload: payload)
                else {
                    return completion(.failure(.connectivityError))
                }
                
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
