//
//  GetInfoRepeatPaymentDomain.GetInfoRepeatPayment+ext.swift
//  Vortex
//
//  Created by Igor Malyarov on 21.12.2024.
//

import GetInfoRepeatPaymentService
import Foundation

extension GetInfoRepeatPaymentDomain.GetInfoRepeatPayment {
    
    // MARK: - delay

    var delay: DispatchTimeInterval {
        switch type.paymentType {
        case .direct, .insideBank, .mobile, .repeatPaymentRequisites, .servicePayment, .sfp:
            return .milliseconds(300)
            
        case .betweenTheir, .byPhone, .otherBank, .taxes:
            return .milliseconds(1300)
            
        case .none:
            return .milliseconds(0)
        }
    }

    // MARK: - Mode
    
    func betweenTheirMode(
        getProduct: @escaping (ProductData.ID) -> ProductData?
    ) -> PaymentsMeToMeViewModel.Mode? {
        
        guard type.paymentType == .betweenTheir else { return nil }
        
        return parameterList.compactMap {
            
            guard let amount = $0.amount,
                  let productID = $0.payerOrInternalPayerProductID,
                  let product = getProduct(productID)
            else { return nil }
            
            return .makePaymentTo(product, amount)
        }
        .first
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
        if let source = mobileSource() {
            return source
        }
        if let source = repeatPaymentRequisitesSource() {
            return source
        }
        if let source = servicePaymentSource() {
            return source
        }
        if let source = sfpSource(activeProductID: activeProductID) {
            return source
        }
        if let source = taxesSource() {
            return source
        }
        if let source = toAnotherCardSource() {
            return source
        }
        
        return nil
    }
    
    func byPhoneSource(
        activeProductID: ProductData.ID
    ) -> Payments.Operation.Source? {
        
        guard type.paymentType == .byPhone,
              let transfer = parameterList.last,
              let phone = transfer.payeeInternal?.phoneNumber,
              let amount = transfer.amount
        else { return nil }
        
        return .sfp(
            phone: phone,
            bankId: Vortex.BankID.vortexID.digits,
            amount: amount.description,
            productId: activeProductID
        )
    }
    
    func directSource(
        date: Date = .init()
    ) -> Payments.Operation.Source? {
        
        guard type.paymentType == .direct,
              let transfer = parameterList.last,
              let additional = transfer.additional,
              let phone = transfer.directPhone,
              let countryId = transfer.countryID
        else { return nil }
        
        return .direct(
            phone: phone,
            countryId: countryId,
            serviceData: .init(
                additionalList: additional.map {
                    
                    return .init(
                        fieldTitle: $0.fieldname,
                        fieldName: $0.fieldname,
                        fieldValue: $0.fieldvalue,
                        svgImage: ""
                    )
                },
                amount: transfer.amount ?? 0,
                date: date, // ???
                paymentDate: "", // ???
                puref: transfer.puref ?? "", // ???
                type: .internet, // ???
                lastPaymentName: nil
            )
        )
    }
    
    func mobileSource() -> Payments.Operation.Source? {
        
        guard type.paymentType == .mobile,
              let transfer = parameterList.last,
              let phone = transfer.mobilePhone,
              let amount = transfer.amount
        else { return nil }
        
        return .mobile(
            phone: "7\(phone)", // ?? or only phone
            amount: amount.description,
            productId: transfer.payerProductID
        )
    }
    
    func repeatPaymentRequisitesSource() -> Payments.Operation.Source? {
        
        guard type.paymentType == .repeatPaymentRequisites,
              let transfer = parameterList.last,
              let amount = transfer.amount?.description,
              let accountNumber = transfer.payeeExternal?.accountNumber,
              let bankBIC = transfer.payeeExternal?.bankBIC
        else { return nil }
        
        return .repeatPaymentRequisites(
            accountNumber: accountNumber,
            bankId: bankBIC,
            inn: transfer.payeeExternal?.inn ?? "",
            kpp: transfer.payeeExternal?.kpp,
            amount: amount,
            productId: transfer.payerProductID,
            comment: transfer.comment
        )
    }
    
    func servicePaymentSource() -> Payments.Operation.Source? {
        
        guard type.paymentType == .servicePayment,
              let puref = parameterList.puref,
              let amount = parameterList.amount
        else { return nil }
        
        return .servicePayment(
            puref: puref,
            additionalList: parameterList.additional.map {
                
                return .init(fieldTitle: $0.fieldname, fieldName: $0.fieldname, fieldValue: $0.fieldvalue, svgImage: nil)
            },
            amount: amount,
            productId: parameterList.productId
        )
    }
    
    func sfpSource(
        activeProductID: ProductData.ID
    ) -> Payments.Operation.Source? {
        
        guard type.paymentType == .sfp,
              let transfer = parameterList.last,
              let phone = transfer.sfpPhone,
              let bankID = transfer.sfpBankID,
              let amount = transfer.amount
        else { return nil }
        
        return .sfp(
            phone: phone,
            bankId: bankID,
            amount: amount.description,
            productId: activeProductID
        )
    }
    
    func taxesSource() -> Payments.Operation.Source? {
        
        type.paymentType == .taxes ? .taxes(parameterData: nil) : nil
    }
    
    func toAnotherCardSource(
    ) -> Payments.Operation.Source? {
        
        guard type.paymentType == .insideBank,
              let transfer = parameterList.last,
              let from = transfer.payer?.cardId,
              let amount = transfer.amount,
              let to = productTemplate?.id
        else { return nil }
        
        return .toAnotherCard(from: from, to: to, amount: amount.description)
    }
}

private extension GetInfoRepeatPaymentDomain.GetInfoRepeatPayment.Transfer {
    
    var countryID: String? {
        
        additional?.first(where: { $0.fieldname == "trnPickupPoint"})?.fieldvalue
    }
    
    var directPhone: String? {
        
        additional?.first(where: { $0.fieldname == "RECP"})?.fieldvalue
    }
    
    var mobilePhone: String? {
        
        additional?.first(where: { $0.fieldname == "a3_NUMBER_1_2"})?.fieldvalue
    }
    
    var sfpBankID: String? {
        
        additional?.first(where: { $0.fieldname == "BankRecipientID"})?.fieldvalue
    }
    
    var sfpPhone: String? {
        
        additional?.first(where: { $0.fieldname == "RecipientID"})?.fieldvalue
    }
    
    var payerOrInternalPayerProductID: Int? {
        
        payerProductID ?? internalPayeeProductID
    }
    
    var payerProductID: Int? {
        
        payer?.cardId ?? payer?.accountId
    }
    
    private var externalPayeeProductID: Int? {
        
        payeeExternal?.cardId ?? payeeExternal?.accountId
    }
    
    private var internalPayeeProductID: Int? {
        
        payeeInternal?.cardId ?? payeeInternal?.accountId
    }
}

private extension Array where Element == GetInfoRepeatPaymentDomain.GetInfoRepeatPayment.Transfer {
    
    var amount: Double? {
        
        for transfer in self {
            
            if let amount = transfer.amount, amount > 0 {
                
                return amount
            }
        }
        
        return nil
    }
    
    var puref: String? {
        
        for transfer in self {
            
            if let puref = transfer.puref, !puref.isEmpty {
                
                return puref
            }
        }
        
        return nil
    }
    
    var additional: [GetInfoRepeatPaymentDomain.GetInfoRepeatPayment.Transfer.Additional] {
        
        if let additional = last?.additional, !additional.isEmpty {
            
            return additional
        }
        
        return first?.additional ?? []
    }
    
    var payerCardId: Int? {
        
        for transfer in self {
            
            if let payerCardId = transfer.payer?.cardId {
                
                return payerCardId
            }
        }
        
        return nil
    }
    
    var payerAccountId: Int? {
        
        for transfer in self {
            
            if let accountId = transfer.payer?.accountId {
                
                return accountId
            }
        }
        
        return nil
    }
    
    var productId: Int? {
        
        return payerCardId ?? payerAccountId
    }
}
