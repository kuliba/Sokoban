//
//  RootViewModelFactory+getInfoRepeatPaymentTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 21.12.2024.
//

import GetInfoRepeatPaymentService

extension GetInfoRepeatPaymentDomain {
    
    enum Navigation {
        
        case direct(PaymentsViewModel)
        case meToMe(PaymentsMeToMeViewModel)
    }
}

extension RootViewModelFactory {
    
    func getInfoRepeatPayment(
        from info: GetInfoRepeatPaymentDomain.GetInfoRepeatPayment,
        closeAction: @escaping () -> Void
    ) -> GetInfoRepeatPaymentDomain.Navigation? {
        
        let products = model.products.value.flatMap(\.value)
        
        return getInfoRepeatPayment(
            from: info,
            getProduct: { id in products.first { $0.id == id }},
            closeAction: closeAction
        )
    }
    
    func getInfoRepeatPayment(
        from info: GetInfoRepeatPaymentDomain.GetInfoRepeatPayment,
        getProduct: @escaping (ProductData.ID) -> ProductData?,
        closeAction: @escaping () -> Void
    ) -> GetInfoRepeatPaymentDomain.Navigation? {
        
        return makeMeToMe(from: info, getProduct: getProduct).map { .meToMe($0) }
        ?? makeDirect(from: info, closeAction: closeAction).map { .direct($0) }
    }
    
    func makeMeToMe(
        from info: GetInfoRepeatPaymentDomain.GetInfoRepeatPayment,
        getProduct: @escaping (ProductData.ID) -> ProductData?
    ) -> PaymentsMeToMeViewModel? {
        
        guard let mode = info.mode(getProduct: getProduct)
        else { return nil }
        
        return .init(model, mode: mode)
    }
    
    func makeDirect(
        from info: GetInfoRepeatPaymentDomain.GetInfoRepeatPayment,
        closeAction: @escaping () -> Void
    ) -> PaymentsViewModel? {
        
        guard let direct = info.direct() else { return nil }
        
        return .init(source: direct, model: model, closeAction: closeAction)
    }
}

@testable import Vortex
import XCTest

final class RootViewModelFactory_getInfoRepeatPaymentTests: GetInfoRepeatPaymentTests {
    
    // MARK: - meToMe
    
    func test_shouldDeliverNilOnNilAmount() throws {
        
        let productID = makeProductID()
        let transfer = makeTransfer(
            amount: nil,
            payer: makePayer(cardId: productID)
        )
        let info = makeBetweenTheir(parameterList: [transfer])
        let model = try makeModelWithMeToMeProduct(
            product: makeProduct(id: productID, currency: "RUB")
        )
        
        assert(model: model, with: info, delivers: nil)
    }
    
    func test_shouldDeliverNilOnEmptyParameterList() throws {
        
        let productID = makeProductID()
        let info = makeBetweenTheir(parameterList: [])
        let model = try makeModelWithMeToMeProduct(
            product: makeProduct(id: productID, currency: "RUB")
        )
        
        assert(model: model, with: info, delivers: nil)
    }
    
    func test_shouldDeliverNilOnExternalPayerProduct() throws {
        
        let productID = makeProductID()
        let transfer = makeTransfer(payeeExternal: makeExternalPayer())
        let info = makeBetweenTheir(parameterList: [transfer])
        let model = try makeModelWithMeToMeProduct(
            product: makeProduct(id: productID, currency: "RUB")
        )
        
        assert(model: model, with: info, delivers: nil)
    }
    
    func test_shouldDeliverMeToMeOnPayerProduct() throws {
        
        let productID = makeProductID()
        let transfer = makeTransfer(payer: makePayer(cardId: productID))
        let info = makeBetweenTheir(parameterList: [transfer])
        let model = try makeModelWithMeToMeProduct(
            product: makeProduct(id: productID, currency: "RUB")
        )
        
        assert(model: model, with: info, delivers: .meToMe)
    }
    
    func test_shouldDeliverMeToMeOnInternalPayerProduct() throws {
        
        let productID = makeProductID()
        let transfer = makeTransfer(payeeInternal: makeInternalPayer(accountId: productID))
        let info = makeBetweenTheir(parameterList: [transfer])
        let model = try makeModelWithMeToMeProduct(
            product: makeProduct(id: productID, currency: "RUB")
        )
        
        assert(model: model, with: info, delivers: .meToMe)
    }
    
    // MARK: - direct, contactAddressless
    
    func test_shouldDeliverDirectOnDirect() throws {
        
        let transfer = makeTransfer(additional: [makePhone(), makeCountryID()])
        let info = makeDirect(parameterList: [transfer])
        
        assert(with: info, delivers: .direct)
    }
    
    func test_shouldDeliverDirectOnContactAddressless() throws{
        
        let transfer = makeTransfer(additional: [makePhone(), makeCountryID()])
        let info = makeAddressless(parameterList: [transfer])
        
        assert(with: info, delivers: .direct)
    }
    
    // MARK: - Helpers
    
    private func makeBetweenTheir(
        parameterList: [Repeat.Transfer] = []
    ) -> Repeat {
        
        return makeRepeat(type: .betweenTheir, parameterList: parameterList)
    }
    
    private func makeDirect(
        parameterList: [Repeat.Transfer] = []
    ) -> Repeat {
        
        return makeRepeat(type: .direct, parameterList: parameterList)
    }
    
    private func makeAddressless(
        parameterList: [Repeat.Transfer] = []
    ) -> Repeat {
        
        return makeRepeat(type: .contactAddressless, parameterList: parameterList)
    }
    
    private func makeTransfer(
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
    
    private func makePhone(
        fieldid: Int = .random(in: 1...100),
        fieldvalue: String = anyMessage()
    ) -> Transfer.Additional {
        
        return .init(fieldname: "RECP", fieldid: fieldid, fieldvalue: fieldvalue)
    }
    
    private func makeCountryID(
        fieldid: Int = .random(in: 1...100),
        fieldvalue: String = anyMessage()
    ) -> Transfer.Additional {
        
        return .init(fieldname: "trnPickupPoint", fieldid: fieldid, fieldvalue: fieldvalue)
    }
    
    private enum EquatableNavigation: Equatable {
        
        case direct
        case meToMe
    }
    
    private func equatable(
        _ navigation: GetInfoRepeatPaymentDomain.Navigation
    ) -> EquatableNavigation {
        
        switch navigation {
        case .direct: return .direct
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
    
    private func assert(
        model: Model = .mockWithEmptyExcept(),
        product: ProductData? = nil,
        closeAction: @escaping () -> Void = {},
        with info: Repeat,
        delivers expectedNavigation: EquatableNavigation?,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let sut = makeSUT(model: model, file: file, line: line).sut
        
        let navigation = sut.getInfoRepeatPayment(
            from: info,
            getProduct: { product ?? self.makeProduct(id: $0) },
            closeAction: closeAction
        )
        
        XCTAssertNoDiff(navigation.map(equatable), expectedNavigation, "Expected \(String(describing: expectedNavigation)), but got \(String(describing: navigation)) instead.", file: file, line: line)
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
