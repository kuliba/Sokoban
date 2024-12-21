//
//  GetInfoRepeatPaymentDomain.GetInfoRepeatPayment+ext.swift
//  Vortex
//
//  Created by Igor Malyarov on 21.12.2024.
//

import GetInfoRepeatPaymentService
import Foundation

extension GetInfoRepeatPaymentDomain.GetInfoRepeatPayment {
    
    func betweenTheirMode(
        getProduct: @escaping (ProductData.ID) -> ProductData?
    ) -> PaymentsMeToMeViewModel.Mode? {
        
        guard type == .betweenTheir else { return nil }
        
        return parameterList.compactMap {
            
            guard let amount = $0.amount,
                  let productID = $0.payerOrInternalPayerProductID,
                  let product = getProduct(productID)
            else { return nil }
            
            return .makePaymentTo(product, amount)
        }
        .first
    }
    
    func directSource(
        date: Date = .init()
    ) -> Payments.Operation.Source? {
        
        guard type == .direct || type == .contactAddressless,
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
    
    func repeatPaymentRequisitesSource() -> Payments.Operation.Source? {
        
        guard type == .externalEntity || type == .externalIndivudual,
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
    
    func toAnotherCardSource(
    ) -> Payments.Operation.Source? {
        
        guard type == .insideBank,
              let transfer = parameterList.last,
              let from = transfer.payer?.cardId,
              let amount = transfer.amount,
              let to = productTemplate?.id
        else { return nil }
        
        return .toAnotherCard(from: from, to: to, amount: amount.description)
    }
    
    func servicePaymentSource() -> Payments.Operation.Source? {
        
        guard type == .internet || type == .transport || type == .housingAndCommunalService,
              let transfer = parameterList.first,
              let puref = transfer.puref,
              let amount = transfer.amount ?? parameterList.last?.amount
        else { return nil }
        
        return .servicePayment(
            puref: puref,
            additionalList: transfer.additional?.map {
                
                return .init(fieldTitle: $0.fieldname, fieldName: $0.fieldname, fieldValue: $0.fieldvalue, svgImage: nil)
            },
            amount: amount,
            productId: transfer.payer?.cardId
        )
    }
    
    func otherBankService() -> Payments.Service? {
        
        type == .otherBank ? .toAnotherCard : nil
    }
    
    func byPhoneSource(
        activeProductID: ProductData.ID
    ) -> Payments.Operation.Source? {
        
        guard type == .byPhone,
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
    
    func sfpSource(
        activeProductID: ProductData.ID
    ) -> Payments.Operation.Source? {
        
        guard type == .sfp,
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
    
    func mobileSource() -> Payments.Operation.Source? {
        
        guard type == .mobile,
              let transfer = parameterList.last,
              let phone = transfer.mobilePhone,
              let amount = transfer.amount
        else { return nil }
        
        return .mobile(
            phone: phone,
            amount: amount.description,
            productId: transfer.payerProductID
        )
    }
    
    func taxesSource() -> Payments.Operation.Source? {
        
        type == .taxes ? .taxes(parameterData: nil) : nil
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
