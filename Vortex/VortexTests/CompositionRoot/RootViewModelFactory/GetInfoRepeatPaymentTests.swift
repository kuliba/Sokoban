//
//  GetInfoRepeatPaymentTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 21.12.2024.
//

import GetInfoRepeatPaymentService

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
    
    // MARK: - betweenTheirMode
    
    func test_betweenTheirMode_shouldDeliverNilOnNonBetweenTheirType() {
        
        for type in allTransferTypes(except: .betweenTheir) {
            
            let info = makeRepeat(type: type)
            
            XCTAssertNil(info.betweenTheirMode(getProduct: { self.makeProduct(id: $0) }))
        }
    }
    
    func test_betweenTheirMode_shouldDeliverNilOnNilAmount() {
        
        let productID = makeProductID()
        let transfer = makeTransfer(
            amount: nil,
            payer: makePayer(cardId: productID)
        )
        let info = makeBetweenTheir(parameterList: [transfer])
        
        XCTAssertNil(info.betweenTheirMode(getProduct: { self.makeProduct(id: $0) }))
    }
    
    func test_betweenTheirMode_shouldDeliverNilOnEmptyParameterList() throws {
        
        let info = makeBetweenTheir(parameterList: [])
        
        XCTAssertNil(info.betweenTheirMode(getProduct: { self.makeProduct(id: $0) }))
    }
    
    func test_betweenTheirMode_shouldDeliverNilOnExternalPayerProduct() throws {
        
        let transfer = makeTransfer(payeeExternal: makeExternalPayer())
        let info = makeBetweenTheir(parameterList: [transfer])
        
        XCTAssertNil(info.betweenTheirMode(getProduct: { self.makeProduct(id: $0) }))
    }
    
    func test_betweenTheirMode_shouldDeliverModeOnPayerProduct() throws {
        
        let productID = makeProductID()
        let product = makeProduct(id: productID)
        let amount = Double.random(in: 1...100)
        let transfer = makeTransfer(
            amount: amount,
            payer: makePayer(cardId: productID)
        )
        let info = makeBetweenTheir(parameterList: [transfer])
        
        XCTAssertNoDiff(
            info.betweenTheirMode(getProduct: { _ in product }),
            .makePaymentTo(product, amount)
        )
    }
    
    func test_betweenTheirMode_shouldDeliverModeOnInternalPayerProduct() throws {
        
        let productID = makeProductID()
        let product = makeProduct(id: productID)
        let amount = Double.random(in: 1...100)
        let transfer = makeTransfer(
            amount: amount,
            payeeInternal: makeInternalPayer(accountId: productID)
        )
        let info = makeBetweenTheir(parameterList: [transfer])
        
        XCTAssertNoDiff(
            info.betweenTheirMode(getProduct: { _ in product }),
            .makePaymentTo(product, amount)
        )
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
    
    func makeBetweenTheir(
        parameterList: [Repeat.Transfer] = []
    ) -> Repeat {
        
        return makeRepeat(type: .betweenTheir, parameterList: parameterList)
    }
    
    func makeRepeat(
        type: TransferType,
        parameterList: [Repeat.Transfer] = [],
        productTemplate: Repeat.ProductTemplate? = nil
    ) -> Repeat {
        
        return .init(type: type, parameterList: parameterList, productTemplate: productTemplate)
    }
    
    func makeProductID() -> ProductData.ID {
        
        return .random(in: 1...1_000)
    }
    
    func makeTransfer(
        check: Bool = false,
        amount: Double? = .random(in: 1...100),
        currencyAmount: String? = nil,
        payer: Transfer.Payer? = nil,
        comment: String? = nil,
        puref: String? = nil,
        payeeInternal: Transfer.PayeeInternal? = nil,
        payeeExternal: Transfer.PayeeExternal? = nil,
        additional: [Transfer.Additional]? = nil,
        mcc: String? = nil
    ) -> Repeat.Transfer {
        
        return .init(
            check: check,
            amount: amount,
            currencyAmount: currencyAmount,
            payer: payer,
            comment: comment,
            puref: puref,
            payeeInternal: payeeInternal,
            payeeExternal: payeeExternal,
            additional: additional,
            mcc: mcc
        )
    }
    
    func makePayer(
        cardId: Int = .random(in: 1...100),
        cardNumber: String? = nil,
        accountId: Int? = nil,
        accountNumber: String? = nil,
        phoneNumber: String? = nil,
        inn: String? = nil
    ) -> Repeat.Transfer.Payer {
        
        return .init(
            cardId: cardId,
            cardNumber: cardNumber,
            accountId: accountId,
            accountNumber: accountNumber,
            phoneNumber: phoneNumber,
            inn: inn
        )
    }
    
    func makeExternalPayer(
        inn: String? = nil,
        kpp: String? = nil,
        accountId: Int? = nil,
        accountNumber: String = anyMessage(),
        bankBIC: String? = nil,
        cardId: Int? = nil,
        cardNumber: String? = nil,
        compilerStatus: String? = nil,
        date: String? = nil,
        name: String = anyMessage()
    ) -> Repeat.Transfer.PayeeExternal {
        
        return .init(
            inn: inn,
            kpp: kpp,
            accountId: accountId,
            accountNumber: accountNumber,
            bankBIC: bankBIC,
            cardId: cardId,
            cardNumber: cardNumber,
            compilerStatus: compilerStatus,
            date: date,
            name: name
        )
    }
    
    func makeInternalPayer(
        accountId: Int? = nil,
        accountNumber: String? = nil,
        cardId: Int? = nil,
        cardNumber: String? = nil,
        phoneNumber: String? = nil,
        productCustomName: String? = nil
    ) -> Repeat.Transfer.PayeeInternal {
        
        return .init(
            accountId: accountId,
            accountNumber: accountNumber,
            cardId: cardId,
            cardNumber: cardNumber,
            phoneNumber: phoneNumber,
            productCustomName: productCustomName
        )
    }
}
