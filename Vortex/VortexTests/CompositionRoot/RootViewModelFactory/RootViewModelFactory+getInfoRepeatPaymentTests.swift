//
//  RootViewModelFactory+getInfoRepeatPaymentTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 21.12.2024.
//

import GetInfoRepeatPaymentService

extension GetInfoRepeatPaymentDomain {
    
    enum Navigation {
        
        case meToMe(PaymentsMeToMeViewModel)
    }
}

extension RootViewModelFactory {
    
    func getInfoRepeatPayment(
        from info: GetInfoRepeatPaymentDomain.GetInfoRepeatPayment
    ) -> GetInfoRepeatPaymentDomain.Navigation? {
        
        let products = model.products.value.flatMap(\.value)
        
        return getInfoRepeatPayment(
            from: info,
            getProduct: { id in products.first { $0.id == id }}
        )
    }
    
    func getInfoRepeatPayment(
        from info: GetInfoRepeatPaymentDomain.GetInfoRepeatPayment,
        getProduct: @escaping (ProductData.ID) -> ProductData?
    ) -> GetInfoRepeatPaymentDomain.Navigation? {
        
        return makeMeToMe(from: info, getProduct: getProduct).map { .meToMe($0) }
    }
    
    func makeMeToMe(
        from info: GetInfoRepeatPaymentDomain.GetInfoRepeatPayment,
        getProduct: @escaping (ProductData.ID) -> ProductData?
    ) -> PaymentsMeToMeViewModel? {
        
        guard let mode = info.mode(getProduct: getProduct)
        else { return nil }
        
        return .init(model, mode: mode)
    }
}

private extension GetInfoRepeatPaymentDomain.GetInfoRepeatPayment {
    
    func mode(
        getProduct: @escaping (ProductData.ID) -> ProductData?
    ) -> PaymentsMeToMeViewModel.Mode? {
        
        return parameterList.compactMap {
            
            guard let amount = $0.amount,
                  let productID = $0.payerOrInternalPayerProductID,
                  let product = getProduct(productID)
            else { return nil }
            
            return .makePaymentTo(product, amount)
        }
        .first
    }
}

private extension GetInfoRepeatPaymentDomain.GetInfoRepeatPayment.Transfer {
    
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

final class RootViewModelFactory_getInfoRepeatPaymentTests: RootViewModelFactoryTests {
    
    // MARK: - meToMe
    
    func test_meToMe_shouldDeliverNilOnNonBetweenTheirType() {
        
        for type in allTransferTypes(except: .betweenTheir) {
            
            let info = makeRepeat(type: type)
            let sut = makeSUT().sut
            
            let meToMe = sut.makeMeToMe(from: info, getProduct: { self.makeProduct(id: $0) })
            
            XCTAssertNil(meToMe)
        }
    }
    
    func test_getInfoRepeatPayment_shouldDeliverNilOnNilAmount() throws {
        
        let productID = makeProductID()
        let transfer = makeTransfer(
            amount: nil,
            payer: makePayer(cardId: productID)
        )
        let info = makeBetweenTheir(parameterList: [transfer])
        let model = try makeModelWithMeToMeProduct(
            product: makeProduct(id: productID, currency: "RUB")
        )
        let sut = makeSUT(model: model).sut

        XCTAssertNil(sut.getInfoRepeatPayment(from: info, getProduct: { self.makeProduct(id: $0) }))
    }
    
    func test_getInfoRepeatPayment_shouldDeliverNilOnEmptyParameterList() throws {
        
        let productID = makeProductID()
        let info = makeBetweenTheir(parameterList: [])
        let model = try makeModelWithMeToMeProduct(
            product: makeProduct(id: productID, currency: "RUB")
        )
        let sut = makeSUT(model: model).sut

        XCTAssertNil(sut.getInfoRepeatPayment(from: info, getProduct: { self.makeProduct(id: $0) }))
    }
    
    func test_getInfoRepeatPayment_shouldDeliverNilOnExternalPayerProduct() throws {
        
        let productID = makeProductID()
        let transfer = makeTransfer(payeeExternal: makeExternalPayer())
        let info = makeBetweenTheir(parameterList: [transfer])
        let model = try makeModelWithMeToMeProduct(
            product: makeProduct(id: productID, currency: "RUB")
        )
        let sut = makeSUT(model: model).sut

        XCTAssertNil(sut.getInfoRepeatPayment(from: info, getProduct: { self.makeProduct(id: $0) }))
    }
    
    func test_getInfoRepeatPayment_shouldDeliverMeToMeOnPayerProduct() throws {
        
        let productID = makeProductID()
        let transfer = makeTransfer(payer: makePayer(cardId: productID))
        let info = makeBetweenTheir(parameterList: [transfer])
        let model = try makeModelWithMeToMeProduct(
            product: makeProduct(id: productID, currency: "RUB")
        )
        let sut = makeSUT(model: model).sut
        
        let navigation = try XCTUnwrap(sut.getInfoRepeatPayment(from: info))
        
        XCTAssertNoDiff(equatable(navigation), .meToMe)
    }
    
    func test_getInfoRepeatPayment_shouldDeliverMeToMeOnInternalPayerProduct() throws {
        
        let productID = makeProductID()
        let transfer = makeTransfer(payeeInternal: makeInternalPayer(accountId: productID))
        let info = makeBetweenTheir(parameterList: [transfer])
        let model = try makeModelWithMeToMeProduct(
            product: makeProduct(id: productID, currency: "RUB")
        )
        let sut = makeSUT(model: model).sut

        let navigation = try XCTUnwrap(sut.getInfoRepeatPayment(from: info, getProduct: { self.makeProduct(id: $0) }))
        
        XCTAssertNoDiff(equatable(navigation), .meToMe)
    }
    
    // MARK: - Helpers
    
    private typealias TransferType = GetInfoRepeatPaymentDomain.GetInfoRepeatPayment.TransferType
    private typealias Repeat = GetInfoRepeatPaymentDomain.GetInfoRepeatPayment
    
    private func allTransferTypes(
        except excludingType: TransferType
    ) -> [TransferType] {
        
        return TransferType.allCases.filter { $0 != excludingType }
    }
    
    private func makeBetweenTheir(
        parameterList: [Repeat.Transfer] = []
    ) -> Repeat {
        
        return makeRepeat(type: .betweenTheir, parameterList: parameterList)
    }
    
    private func makeRepeat(
        type: TransferType,
        parameterList: [Repeat.Transfer] = [],
        productTemplate: Repeat.ProductTemplate? = nil
    ) -> Repeat {
        
        return .init(type: type, parameterList: parameterList, productTemplate: productTemplate)
    }
    
    private func makeTransfer(
        check: Bool = false,
        amount: Double? = .random(in: 1...100),
        currencyAmount: String? = nil,
        payer: GetInfoRepeatPaymentDomain.GetInfoRepeatPayment.Transfer.Payer? = nil,
        comment: String? = nil,
        puref: String? = nil,
        payeeInternal: GetInfoRepeatPaymentDomain.GetInfoRepeatPayment.Transfer.PayeeInternal? = nil,
        payeeExternal: GetInfoRepeatPaymentDomain.GetInfoRepeatPayment.Transfer.PayeeExternal? = nil,
        additional: [GetInfoRepeatPaymentDomain.GetInfoRepeatPayment.Transfer.Additional]? = nil,
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
    
    private enum EquatableNavigation: Equatable {
        
        case meToMe
    }
    
    private func equatable(
        _ navigation: GetInfoRepeatPaymentDomain.Navigation
    ) -> EquatableNavigation {
        
        switch navigation {
        case .meToMe: return .meToMe
        }
    }
    
    private func makeProductID() -> ProductData.ID {
        
        return .random(in: 1...1_000)
    }
    
    private func makeModelWithMeToMeProduct(
        product: ProductData? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> Model {
        
        let model: Model = .mockWithEmptyExcept()
        try model.addMeToMeProduct(product: product, file: file, line: line)
        
        return model
    }
    
    private func makePayer(
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
    
    private func makeExternalPayer(
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
    
    private func makeInternalPayer(
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

extension XCTestCase {
    
    func makeProduct(
        id: Int = .random(in: 1...100),
        productType: ProductType = .account,
        number: String? = nil,
        numberMasked: String? = nil,
        accountNumber: String? = nil,
        balance: Double? = nil,
        balanceRub: Double? = nil,
        currency: String = anyMessage(),
        mainField: String = anyMessage(),
        additionalField: String? = nil,
        customName: String? = nil,
        productName: String = anyMessage(),
        openDate: Date? = nil,
        ownerId: Int = .random(in: 1...100),
        branchId: Int? = nil,
        allowCredit: Bool = true,
        allowDebit: Bool = true,
        extraLargeDesign: SVGImageData = .test,
        largeDesign: SVGImageData = .test,
        mediumDesign: SVGImageData = .test,
        smallDesign: SVGImageData = .test,
        fontDesignColor: ColorData = .init(description: anyMessage()),
        background: [ColorData] = [],
        order: Int = .random(in: 1...100),
        isVisible: Bool = true,
        smallDesignMd5hash: String = anyMessage(),
        smallBackgroundDesignHash: String = anyMessage()
    ) -> ProductData {
        
        return .init(
            id: id,
            productType: productType,
            number: number,
            numberMasked: numberMasked,
            accountNumber: accountNumber,
            balance: balance,
            balanceRub: balanceRub,
            currency: currency,
            mainField: mainField,
            additionalField: additionalField,
            customName: customName,
            productName: productName,
            openDate: openDate,
            ownerId: ownerId,
            branchId: branchId,
            allowCredit: allowCredit,
            allowDebit: allowDebit,
            extraLargeDesign: extraLargeDesign,
            largeDesign: largeDesign,
            mediumDesign: mediumDesign,
            smallDesign: smallDesign,
            fontDesignColor: fontDesignColor,
            background: background,
            order: order,
            isVisible: isVisible,
            smallDesignMd5hash: smallDesignMd5hash,
            smallBackgroundDesignHash: smallBackgroundDesignHash
        )
    }
}
