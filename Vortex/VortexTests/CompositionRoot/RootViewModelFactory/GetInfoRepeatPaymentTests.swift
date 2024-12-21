//
//  GetInfoRepeatPaymentTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 21.12.2024.
//

import GetInfoRepeatPaymentService

extension GetInfoRepeatPaymentDomain.GetInfoRepeatPayment {
    
    func mode(
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
    
    func direct() -> Payments.Operation.Source? {
        
        guard type == .direct || type == .contactAddressless
        else { return nil }
        
        guard let transfer = parameterList.last,
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
                date: Date(), // ???
                paymentDate: "", // ???
                puref: transfer.puref ?? "", // ???
                type: .internet, // ???
                lastPaymentName: nil
            )
        )
    }
}

private extension GetInfoRepeatPaymentDomain.GetInfoRepeatPayment.Transfer {
    
    var countryID: String? {
        
        additional?.first(where: { $0.fieldname == "trnPickupPoint"})?.fieldvalue
    }
    
    var directPhone: String? {
        
        additional?.first(where: { $0.fieldname == "RECP"})?.fieldvalue
    }
    
    var payerOrInternalPayerProductID: Int? {
        
        payerProductID ?? internalPayeeProductID
    }
    
    private var payerProductID: Int? {
        
        payer?.cardId ?? payer?.accountId
    }
    
    private var externalPayeeProductID: Int? {
        
        payeeExternal?.cardId ?? payeeExternal?.accountId
    }
    
    private var internalPayeeProductID: Int? {
        
        payeeInternal?.cardId ?? payeeInternal?.accountId
    }
}

@testable import Vortex
import XCTest

class GetInfoRepeatPaymentTests: RootViewModelFactoryTests {
    
    // MARK: - meToMe
    
    func test_meToMe_shouldDeliverNilOnNonBetweenTheirType() {
        
        for type in allTransferTypes(except: .betweenTheir) {
            
            let info = makeRepeat(type: type)
            let sut = makeSUT().sut
            
            let meToMe = sut.makeMeToMe(from: info, getProduct: { self.makeProduct(id: $0) })
            
            XCTAssertNil(meToMe)
        }
    }
    
    // MARK: - Helpers
    
    typealias Repeat = GetInfoRepeatPaymentDomain.GetInfoRepeatPayment
    typealias Transfer = Repeat.Transfer
    typealias TransferType = Repeat.TransferType
    
    func allTransferTypes(
        except excludingType: TransferType
    ) -> [TransferType] {
        
        return TransferType.allCases.filter { $0 != excludingType }
    }
    
    func makeRepeat(
        type: TransferType,
        parameterList: [Repeat.Transfer] = [],
        productTemplate: Repeat.ProductTemplate? = nil
    ) -> Repeat {
        
        return .init(type: type, parameterList: parameterList, productTemplate: productTemplate)
    }
}
