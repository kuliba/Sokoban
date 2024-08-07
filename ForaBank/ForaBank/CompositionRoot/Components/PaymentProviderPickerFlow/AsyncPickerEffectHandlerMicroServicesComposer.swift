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
    
    private let model: Model
    private let nanoServices: NanoServices
    
    init(
        model: Model,
        nanoServices: NanoServices
    ) {
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
                
                let context = AnywayPaymentContext(
                    response: response,
                    item: item,
                    payload: payload,
                    product: self.model.outlineProduct()
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
        item: ServicePickerItem,
        payload: PaymentProviderServicePickerPayload,
        product: AnywayPaymentOutline.Product
    ) {
        let outline = AnywayPaymentOutline(
            service: item.service,
            payload: payload,
            product: product
        )
        let firstField = AnywayElement.Field(
            item: item,
            provider: payload.provider.origin
        )
        let initialPayment = AnywayPaymentDomain.AnywayPayment(
            amount: outline.amount,
            elements: [firstField.map { .field($0) }].compactMap { $0 },
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

private extension AnywayElement.Field {
    
    init?(
        item: ServicePickerItem,
        provider: UtilityPaymentProvider
    ) {
        guard item.isOneOf else { return nil }
        
        self.init(
            id: "_selected_service", 
            title: "Услуга",
            value: item.service.name,
            icon: provider.icon.map { .md5Hash($0) }
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
        payload: PaymentProviderServicePickerPayload,
        product: AnywayPaymentOutline.Product
    ) {
        let fields = payload.fields(matching: service.puref)
        
        self.init(
            amount: payload.amount,
            product: product,
            fields: fields,
            payload: .init(
                puref: service.puref,
                title: payload.provider.origin.title,
                subtitle: payload.provider.origin.inn,
                icon: payload.provider.origin.icon
            )
        )
    }
}

private extension PaymentProviderServicePickerPayload {
    
    var amount: Decimal? {
        
        do {
            let double: Double = try qrCode.value(
                type: .general(.amount),
                mapping: qrMapping
            )
            return .init(double)
        } catch {
            return nil
        }
    }
    
    func fields(
        matching `operator`: String
    ) -> [String: String] {
        
        let parameters = qrMapping.operators
            .filter { $0.operator == `operator` }
            .flatMap(\.parameters)
        
        let pairs = parameters
            .flatMap { parameter in
                
                parameter.keys.map { ($0, parameter.parameter.name) }
            }
        
        let dict = Dictionary(pairs) { _, last in last }
        
        let fields = qrCode.rawData.compactMap { element in
            
            dict[element.key].map { ($0, element.value) }
        }
        
        return .init(fields) { _, last in last }
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
