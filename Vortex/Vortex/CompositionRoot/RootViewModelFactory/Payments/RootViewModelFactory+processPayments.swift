//
//  RootViewModelFactory+processPayments.swift
//  Vortex
//
//  Created by Igor Malyarov on 24.12.2024.
//

import Foundation

extension RootViewModelFactory {
    
    typealias GetCategoryTypeCompletion = (ServiceCategory.CategoryType?) -> Void
    typealias GetCategoryType = (String, @escaping GetCategoryTypeCompletion) -> Void
    
    @inlinable
    func processPayments(
        lastPayment: UtilityPaymentLastPayment,
        notify: @escaping (AnywayFlowState.Status.Outside) -> Void,
        completion: @escaping (PaymentsDomain.Navigation?) -> Void
    ) {
        let paymentFlow = lastPayment.paymentFlow
        
        switch paymentFlow {
        case "qr":
            return completion(nil)
            
        case "standard":
            processPayments(repeatPayment: lastPayment, notify: notify, completion: completion)
            
        default: // .none,  .mobile, .taxAndStateServices, .transport
            
            let filter = ProductData.Filter.generalFrom
            guard let product = model.firstProduct(with: filter),
                  let paymentsPayload = lastPayment.paymentsPayload(activeProductID: product.id, getProduct: model.product(productId:))
            else { return completion(nil) }
            
            return completion(getPaymentsNavigation(
                from: paymentsPayload,
                closeAction: { notify(.main) }
            ))
        }
    }
    
    func processPayments(
        repeatPayment: RepeatPayment,
        notify: @escaping (AnywayFlowState.Status.Outside) -> Void,
        completion: @escaping (PaymentsDomain.Navigation?) -> Void
    ) {
        
        processSelection(
            select: .payment(repeatPayment)
        ) { [weak self] in
            
            guard let self,
                  case let .success(.startPayment(transaction)) = $0
            else { return completion(nil) }
            
            let flowModel = makeAnywayFlowModel(transaction: transaction)
            let cancellable = flowModel.$state.compactMap(\.outside)
                .sink { notify($0) }
            
            completion(.anywayPayment(.init(
                model: flowModel,
                cancellable: cancellable
            )))
        }
    }
}

private extension UtilityPaymentLastPayment {
    
    func paymentsPayload(
        activeProductID: ProductData.ID,
        getProduct: @escaping (ProductData.ID) -> ProductData?
    ) -> PaymentsDomain.PaymentsPayload? {
        
        if let source = source(activeProductID: activeProductID, getProduct: getProduct) {
            
            return .source(source)
        }
        
        if let service = otherBankService() {
            
            return .service(service)
        }
        
        return .source(.servicePayment(puref:  puref, additionalList: additionalItems.map {
            .init(fieldTitle: $0.fieldTitle, fieldName: $0.fieldName, fieldValue: $0.fieldValue, svgImage: $0.svgImage)
        }, amount: Double(truncating: amount as NSNumber), productId: activeProductID))
    }
    
    // MARK: - Service
    
    func otherBankService() -> Payments.Service? {
        
        type.paymentType == .otherBank ? .toAnotherCard : nil
    }
    
    // MARK: - Source
    
    func source(
        activeProductID: ProductData.ID,
        getProduct: @escaping (ProductData.ID) -> ProductData?
    ) -> Payments.Operation.Source? {
        
        if let source = byPhoneSource(activeProductID: activeProductID) {
            return source
        }
        if let source = directSource() {
            return source
        }
        if let source = mobileSource(activeProductID: activeProductID) {
            return source
        }
        if let source = sfpSource(activeProductID: activeProductID) {
            return source
        }
        if let source = taxesSource() {
            return source
        }
        return nil
    }
    
    func byPhoneSource(
        activeProductID: ProductData.ID
    ) -> Payments.Operation.Source? {
        
        guard type == "phone",
              let phone = mobilePhone
        else { return nil }
        
        return .sfp(
            phone: phone,
            bankId: Vortex.BankID.vortexID.digits,
            amount: "\(amount)",
            productId: activeProductID
        )
    }
    
    func directSource(
        date: Date = .init()
    ) -> Payments.Operation.Source? {
        
        guard type == "outside",
              let countryId = countryID
        else { return nil }
        
        return .direct(
            phone: nil,
            countryId: countryId,
            serviceData: .init(
                additionalList: additionalItems.map {
                    
                    return .init(
                        fieldTitle: $0.fieldName,
                        fieldName: $0.fieldName,
                        fieldValue: $0.fieldValue,
                        svgImage: $0.svgImage
                    )
                },
                amount: NSDecimalNumber(decimal: amount).doubleValue,
                date: date, // ???
                paymentDate: "", // ???
                puref: puref,
                type: .internet, // ???
                lastPaymentName: nil
            )
        )
    }
    
    func mobileSource(
        activeProductID: ProductData.ID
    ) -> Payments.Operation.Source? {
        
        guard type == "mobile",
              let phone = mobilePhone
        else { return nil }
        
        return .mobile(
            phone: "7\(phone)",
            amount: amount.description,
            productId: activeProductID
        )
    }
    
    func sfpSource(
        activeProductID: ProductData.ID
    ) -> Payments.Operation.Source? {
        
        guard type == "phone",
              let phone = sfpPhone,
              let bankID = sfpBankID
        else { return nil }
        
        return .sfp(
            phone: phone,
            bankId: bankID,
            amount: "\(amount)",
            productId: activeProductID
        )
    }
    
    func taxesSource() -> Payments.Operation.Source? {
        
        type == "taxAndStateService" ? .taxes(parameterData: nil) : nil
    }
}

private extension UtilityPaymentLastPayment {
    
    var countryID: String? {
        
        additionalItems.first(where: { $0.fieldName == "trnPickupPoint"})?.fieldValue
    }
    
    var directPhone: String? {
        
        additionalItems.first(where: { $0.fieldName == "RECP"})?.fieldValue
    }
    
    var mobilePhone: String? {
        
        additionalItems.first(where: { $0.fieldName == "a3_NUMBER_1_2"})?.fieldValue
    }
    
    var sfpBankID: String? {
        
        additionalItems.first(where: { $0.fieldName == "BankRecipientID"})?.fieldValue
    }
    
    var sfpPhone: String? {
        
        additionalItems.first(where: { $0.fieldName == "RecipientID"})?.fieldValue
    }
    
    var directAccountID: String? {
        
        additionalItems.first(where: { $0.fieldName == "P1"})?.fieldValue
    }
}

extension Array where Element == UtilityPaymentLastPayment {
    
    var additional: [UtilityPaymentLastPayment.AdditionalItem] {
        
        if let additional = last?.additionalItems, !additional.isEmpty {
            
            return additional
        }
        
        return []
    }
}

