//
//  AnywayPaymentSourceParser.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 11.08.2024.
//

import AnywayPaymentDomain
import RemoteServices
#warning("REMOVE AFTER MOVING TO PROD")
@testable import ForaBank

final class AnywayPaymentSourceParser {
    
    private let getOutlineProduct: GetOutlineProduct
    
    init(
        getOutlineProduct: @escaping GetOutlineProduct
    ) {
        self.getOutlineProduct = getOutlineProduct
    }
    
    typealias GetOutlineProduct = (Source) -> AnywayPaymentOutline.Product?
}

extension AnywayPaymentSourceParser {
    
    enum Source: Equatable {
        
        case latest(Latest)
        case oneOf(Service, Operator)
        case picked(ServicePickerItem, PaymentProviderServicePickerPayload)
        case single(Service, Operator)
        
        typealias Latest = RemoteServices.ResponseMapper.LatestServicePayment
        typealias Operator = UtilityPaymentOperator
        typealias Service = UtilityService
    }
    
    struct Output: Equatable {
        
        let outline: AnywayPaymentOutline
        let firstField: AnywayElement.Field?
    }
    
    func parse(source: Source) throws -> Output {
        
        guard let product = getOutlineProduct(for: source)
        else { throw ParsingError.missingProduct }
        
        switch source {
        case let .latest(latest):
            return self.latest(latest, product)
            
        case let .oneOf(service, `operator`):
            return oneOf(service, `operator`, product)
            
        case let .picked(item, payload):
            return picked(item, payload, product)
            
        case let .single(service, `operator`):
            return single(service, `operator`, product)
        }
    }
    
    enum ParsingError: Error, Equatable {
        
        case missingProduct
    }
}

private extension AnywayPaymentSourceParser {
    
    func getOutlineProduct(
        for source: Source
    ) -> AnywayPaymentOutline.Product? {
        // TODO: implement extraction of particular product with fallback to first eligible
        getOutlineProduct(source)
    }
    
    func latest(
        _ latest: Source.Latest,
        _ product: AnywayPaymentOutline.Product
    ) -> Output {
        
        return .init(
            outline: .init(
                latestServicePayment: latest,
                product: product
            ),
            firstField: nil
        )
    }
    
    func oneOf(
        _ service: Source.Service,
        _ `operator`: Source.Operator,
        _ product: AnywayPaymentOutline.Product
    ) -> Output {
        
        return .init(
            outline: .init(
                operator: `operator`,
                puref: service.puref,
                product: product
            ),
            firstField: .init(
                service: service,
                icon: `operator`.icon
            )
        )
    }
    
    func picked(
        _ item: ServicePickerItem,
        _ payload: PaymentProviderServicePickerPayload,
        _ product: AnywayPaymentOutline.Product
    ) -> Output {
        
        return .init(
            outline: .init(
                service: item.service,
                payload: payload,
                product: product
            ),
            firstField: .init(
                service: item.isOneOf ? item.service : nil,
                icon: payload.provider.origin.icon
            )
        )
    }
    
    func single(
    _ service: Source.Service,
    _ `operator`: Source.Operator,
    _ product: AnywayPaymentOutline.Product
    ) -> Output {
        
        return .init(
            outline: .init(
                operator: `operator`,
                puref: service.puref,
                product: product
            ),
            firstField: nil
        )
    }
}
