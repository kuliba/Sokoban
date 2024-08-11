//
//  AnywayPaymentSourceParser.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 11.08.2024.
//

import AnywayPaymentDomain
import Foundation
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
        case template(PaymentTemplateData)
        
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
            
        case let .template(template):
            return try self.template(template, product)
        }
    }
    
    enum ParsingError: Error, Equatable {
        
        case missingProduct, templateParsingFailure
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
    
    func template(
        _ template: PaymentTemplateData,
        _ product: AnywayPaymentOutline.Product
    ) throws -> Output {
        
        guard let outline = template.outline else {
            
            throw ParsingError.templateParsingFailure
        }
        
        return .init(
            outline: outline,
            firstField: nil
        )
    }
}

// MARK: - Helpers

private extension PaymentTemplateData {
    
    var outline: AnywayPaymentOutline? {
        
        let asTransferAnywayData = parameterList
            .compactMap { $0 as? TransferAnywayData }
        
        let cores = asTransferAnywayData
            .compactMap { data -> (amount: Decimal, currency: String, product: TransferData.Payer.Product, puref: String)? in
                
                guard let amount = data.amount,
                      let currency = data.currencyAmount,
                      let payer = data.payer,
                      let product = payer.product,
                      let puref = data.puref
                else { return nil }
                
                return (amount, currency, product, puref)
            }
        
        guard let core = cores.first else { return nil }
        
        let product = AnywayPaymentOutline.Product(currency: core.currency, productID: core.product.id, productType: core.product.type)
        
        let fields = asTransferAnywayData.flatMap(\.additional).map { ($0.fieldname, $0.fieldvalue) }
        
        return .init(
            amount: core.amount,
            product: product,
            fields: .init(fields) { _, last in last },
            payload: .init(
                puref: core.puref,
                title: name,
                subtitle: groupName,
                icon: svgImage.description
            )
        )
    }
}

private extension TransferData.Payer {
    
    var product: Product? {
        
        if let accountId {
            
            return .init(id: accountId, type: .account)
        }
        
        if let cardId {
            
            return .init(id: cardId, type: .card)
        }
        
        return nil
    }
    
    struct Product: Equatable {
        
        let id: Int
        let type: AnywayPaymentOutline.Product.ProductType
    }
}
