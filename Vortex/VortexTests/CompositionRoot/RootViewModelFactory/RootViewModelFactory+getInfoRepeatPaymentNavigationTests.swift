//
//  RootViewModelFactory+getInfoRepeatPaymentNavigationTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 21.12.2024.
//

import GetInfoRepeatPaymentService
@testable import Vortex
import XCTest

final class RootViewModelFactory_getInfoRepeatPaymentNavigationTests: GetInfoRepeatPaymentTests {
    
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
        let product = makeProduct(id: productID, productType: .card, currency: "RUB")
        let transfer = makeTransfer(payer: makePayer(cardId: productID))
        let info = makeBetweenTheir(parameterList: [transfer])
        let model = try makeModelWithMeToMeProduct(product: product)
        
        assert(model: model, product: product, with: info, delivers: .meToMe)
    }
    
    func test_shouldDeliverMeToMeOnInternalPayerProduct() throws {
        
        let productID = makeProductID()
        let product = makeProduct(id: productID, productType: .account, currency: "RUB")
        let transfer = makeTransfer(payeeInternal: makeInternalPayer(accountId: productID))
        let info = makeBetweenTheir(parameterList: [transfer])
        let model = try makeModelWithMeToMeProduct(product: product)
        
        assert(model: model, product: product, with: info, delivers: .meToMe)
    }
    
    // MARK: - direct, contactAddressless
    
    func test_shouldDeliverPaymentsOnDirect() {
        
        let transfer = makeTransfer(additional: [makePhone(), makeCountryID()])
        let info = makeDirect(parameterList: [transfer])
        
        assert(with: info, delivers: .payments)
    }
    
    func test_shouldDeliverDirectOnContactAddressless(){
        
        let transfer = makeTransfer(additional: [makePhone(), makeCountryID()])
        let info = makeAddressless(parameterList: [transfer])
        
        assert(with: info, delivers: .payments)
    }
    
    // MARK: - externalEntity, externalIndivudual
    
    func test_shouldDeliverPaymentsOnExternalEntity() throws {
        
        let transfer = makeTransfer(
            payeeExternal: makeExternalPayer(
                inn: anyMessage(),
                bankBIC: anyMessage()
            )
        )
        let info = makeRepeat(type: .externalEntity, parameterList: [transfer])
        
        assert(with: info, delivers: .payments)
    }
    
    func test_shouldDeliverPaymentsOnExternalIndivudual() throws {
        
        let transfer = makeTransfer(
            payeeExternal: makeExternalPayer(
                inn: anyMessage(),
                bankBIC: anyMessage()
            )
        )
        let info = makeRepeat(type: .externalIndividual, parameterList: [transfer])
        
        assert(with: info, delivers: .payments)
    }
    
    // MARK: - insideBank
    
    func test_shouldDeliverPaymentsOnInsideBank() throws {
        
        let transfer = makeTransfer(payer: makePayer())
        let productTemplate = makeProductTemplate()
        let info = makeRepeat(
            type: .insideBank,
            parameterList: [transfer],
            productTemplate: productTemplate
        )
        
        assert(with: info, delivers: .payments)
    }
    
    // MARK: - internet, transport, housingAndCommunalService
    
    func test_shouldDeliverPaymentsOnInternet() {
        
        let additional = makeAdditional()
        let transfer = makeTransfer(
            puref: anyMessage(),
            additional: [additional]
        )
        let info = makeRepeat(type: .internet, parameterList: [transfer])
        
        assert(with: info, delivers: .payments)
    }
    
    func test_shouldDeliverPaymentsOnTransport() {
        
        let additional = makeAdditional()
        let transfer = makeTransfer(
            puref: anyMessage(),
            additional: [additional]
        )
        let info = makeRepeat(type: .transport, parameterList: [transfer])
        
        assert(with: info, delivers: .payments)
    }
    
    func test_shouldDeliverPaymentsOnHousingAndCommunalService() {
        
        let additional = makeAdditional()
        let transfer = makeTransfer(
            puref: anyMessage(),
            additional: [additional]
        )
        let info = makeRepeat(type: .housingAndCommunalService, parameterList: [transfer])
        
        assert(with: info, delivers: .payments)
    }
    
    // MARK: - byPhone
    
    func test_shouldDeliverPaymentsOnByPhone() {
        
        let transfer = makeTransfer(
            payeeInternal: makeInternalPayer(phoneNumber: anyMessage())
        )
        let info = makeRepeat(type: .byPhone, parameterList: [transfer])
        
        assert(with: info, delivers: .payments)
    }
    
    // MARK: - sfp
    
    func test_shouldDeliverPaymentsOnSFP() {
        
        let (phone, bankID) = (anyMessage(), anyMessage())
        let transfer = makeTransfer(
            additional: [
                makeAdditional(fieldname: "RecipientID", fieldvalue: phone),
                makeAdditional(fieldname: "BankRecipientID", fieldvalue: bankID)
            ]
        )
        let info = makeRepeat(type: .sfp, parameterList: [transfer])
        
        assert(with: info, delivers: .payments)
    }
    
    // MARK: - mobile
    
    func test_shouldDeliverPaymentsOnMobile() {
        
        let phone = anyMessage()
        let transfer = makeTransfer(
            additional: [makeAdditional(fieldname: "a3_NUMBER_1_2", fieldvalue: phone)]
        )
        let info = makeRepeat(type: .mobile, parameterList: [transfer])
        
        assert(with: info, delivers: .payments)
    }
    
    // MARK: - taxes
    
    func test_shouldDeliverPaymentsOnTaxes() {
        
        let info = makeRepeat(type: .taxes)
        
        assert(with: info, delivers: .payments)
    }
    
    // MARK: - otherBank
    
    func test_shouldDeliverPaymentsOnOtherBank() {
        
        let info = makeRepeat(type: .otherBank)
        
        assert(with: info, delivers: .payments)
    }
    
    // MARK: - Helpers
    
    private typealias Payload = PaymentsDomain.PaymentsPayload
    
    private func makeDirect(
        parameterList: [Repeat.Transfer] = []
    ) -> Repeat {
        
        return makeRepeat(type: ._direct, parameterList: parameterList)
    }
    
    private func makeAddressless(
        parameterList: [Repeat.Transfer] = []
    ) -> Repeat {
        
        return makeRepeat(type: .contactAddressless, parameterList: parameterList)
    }
    
    private enum EquatableNavigation: Equatable {
        
        case meToMe
        case payments
    }
    
    private func equatable(
        _ navigation: PaymentsDomain.Navigation
    ) -> EquatableNavigation {
        
        switch navigation {
        case .meToMe:   return .meToMe
        case .payments: return .payments
        }
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
    
    private func assert(
        model: Model = .mockWithEmptyExcept(),
        closeAction: @escaping () -> Void = {},
        product: ProductData? = nil,
        with info: Repeat,
        delivers expectedNavigation: EquatableNavigation?,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let sut = makeSUT(model: model, file: file, line: line).sut
        
        let navigation = sut.getInfoRepeatPaymentNavigation(
            from: info,
            activeProductID: makeProductID(),
            getProduct: { _ in product },
            closeAction: closeAction
        )
        
        XCTAssertNoDiff(navigation.map(equatable), expectedNavigation, "Expected \(String(describing: expectedNavigation)), but got \(String(describing: navigation)) instead.", file: file, line: line)
    }
}
