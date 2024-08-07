//
//  AnywayTransactionComposer.swift
//  ForaBank
//
//  Created by Igor Malyarov on 07.08.2024.
//

import AnywayPaymentCore
import AnywayPaymentDomain
import Foundation
import RemoteServices

final class AnywayTransactionComposer {
    
    private let model: Model
    private let validator: Validator
    
    init(
        model: Model,
        validator: Validator
    ) {
        self.model = model
        self.validator = validator
    }
    
    typealias Validator = AnywayPaymentContextValidator
}

extension AnywayTransactionComposer {
    
    typealias AnywayResponse = RemoteServices.ResponseMapper.CreateAnywayTransferResponse
    
    func makeTransaction(
        from response: AnywayResponse,
        item: ServicePickerItem,
        payload: PaymentProviderServicePickerPayload
    ) -> AnywayTransactionState.Transaction? {
        
        guard let update = AnywayPaymentUpdate(response),
              let product = model.outlineProduct()
        else { return nil }
        
        let outline = AnywayPaymentOutline(
            service: item.service,
            payload: payload,
            product: product
        )
        let firstField = AnywayElement.Field(
            service: item.isOneOf ? item.service : nil,
            icon: payload.provider.origin.icon
        )
        let context = AnywayPaymentContext(
            update: update,
            outline: outline,
            firstField: firstField,
            product: product
        )
        
        return .init(
            context: context,
            isValid: validator.validate(context) == nil
        )
    }
    
    func makeTransaction(
        from response: AnywayResponse,
        with payload: MakeAnywayTransactionPayload
    ) -> AnywayTransactionState.Transaction? {
        
        guard let update = AnywayPaymentUpdate(response),
              let product = model.outlineProduct()
        else { return nil }

        switch payload {
        case let .lastPayment(lastPayment):
            return makeTransaction(
                update: update,
                product: product,
                lastPayment: lastPayment
            )
                        
        case let .oneOf(utilityService, `operator`):
            return makeTransaction(
                update: update,
                product: product,
                service: utilityService,
                operator: `operator`
            )
            
        case let .singleService(utilityService, `operator`):
            return makeTransaction(
                update: update,
                product: product,
                puref: utilityService.puref,
                operator: `operator`
            )
        }
    }
}
    
private extension AnywayTransactionComposer {
    
    func makeTransaction(
        update: AnywayPaymentUpdate,
        product: AnywayPaymentOutline.Product,
        lastPayment: UtilityPaymentLastPayment
    ) -> AnywayTransactionState.Transaction? {
        
        let outline = AnywayPaymentOutline(
            latestServicePayment: lastPayment,
            product: product
        )
        let context = AnywayPaymentContext(
            update: update,
            outline: outline,
            firstField: nil,
            product: product
        )
        
        return .init(
            context: context,
            isValid: validator.validate(context) == nil
        )
    }
    
    func makeTransaction(
        update: AnywayPaymentUpdate,
        product: AnywayPaymentOutline.Product,
        service: UtilityService,
        operator: UtilityPaymentOperator
    ) -> AnywayTransactionState.Transaction? {
        
        let outline = AnywayPaymentOutline(
            operator: `operator`,
            puref: service.puref,
            product: product
        )
        let firstField = AnywayElement.Field(
            service: service,
            icon: `operator`.icon
        )
        let context = AnywayPaymentContext(
            update: update,
            outline: outline,
            firstField: firstField,
            product: product
        )
        
        return .init(
            context: context,
            isValid: validator.validate(context) == nil
        )
    }
    
    func makeTransaction(
        update: AnywayPaymentUpdate,
        product: AnywayPaymentOutline.Product,
        puref: String,
        operator: UtilityPaymentOperator
    ) -> AnywayTransactionState.Transaction? {
        
        let outline = AnywayPaymentOutline(
            operator: `operator`,
            puref: puref,
            product: product
        )
        let context = AnywayPaymentContext(
            update: update,
            outline: outline,
            firstField: nil,
            product: product
        )
        
        return .init(
            context: context,
            isValid: validator.validate(context) == nil
        )
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

extension AnywayElement.Field {
    
    init?(
        service: UtilityService?,
        icon: String?
    ) {
        guard let service else { return nil }
        
        self.init(
            id: "_selected_service",
            title: "Услуга",
            value: service.name,
            icon: icon.map { .md5Hash($0) }
        )
    }
}

private extension AnywayPaymentContext {
    
    init(
        update: AnywayPaymentUpdate,
        outline: AnywayPaymentOutline,
        firstField: AnywayElement.Field?,
        product: AnywayPaymentOutline.Product
    ) {
        let initialPayment = AnywayPaymentDomain.AnywayPayment(
            amount: outline.amount,
            elements: [firstField.map { .field($0) }].compactMap { $0 },
            footer: .continue,
            isFinalStep: false
        )
        
        self.init(
            initial: initialPayment,
            payment: initialPayment.update(with: update, and: outline),
            staged: .init(),
            outline: outline,
            shouldRestart: false
        )
    }
}

extension AnywayPaymentOutline {
    
    init(
        latestServicePayment latest: RemoteServices.ResponseMapper.LatestServicePayment,
        product: AnywayPaymentOutline.Product
    ) {
        let pairs = latest.additionalItems.map {
            
            ($0.fieldName, $0.fieldValue)
        }
        let fields = Dictionary(uniqueKeysWithValues: pairs)
        
        self.init(
            amount: latest.amount,
            product: product,
            fields: fields,
            payload: .init(
                puref: latest.puref,
                title: latest.name,
                subtitle: nil,
                icon: latest.md5Hash
            )
        )
    }
    
    init(
        operator: UtilityPaymentOperator,
        puref: String,
        product: AnywayPaymentOutline.Product
    ) {
        self.init(
            amount: nil,
            product: product,
            fields: [:],
            payload: .init(
                puref: puref,
                title: `operator`.title,
                subtitle: `operator`.subtitle,
                icon: `operator`.icon
            )
        )
    }
}
