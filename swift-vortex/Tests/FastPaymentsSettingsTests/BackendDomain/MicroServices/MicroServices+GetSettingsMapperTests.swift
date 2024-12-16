//
//  MicroServices+GetSettingsMapperTests.swift
//
//
//  Created by Igor Malyarov on 26.01.2024.
//

import FastPaymentsSettings
import XCTest

final class MicroServices_GetSettingsMapperTests: XCTestCase {
    
    func test_mapToSettings_shouldSetContract() {
        
        let loadedContract = paymentContract()
        
        let settings = map(paymentContract: loadedContract)
        
        XCTAssertNoDiff(contract(in: settings), loadedContract)
    }
    
    func test_mapToSettings_shouldSetBankDefault() {
        
        let loadedBankDefault = bankDefault(.onDisabled)
        
        let settings = map(bankDefaultResponse: loadedBankDefault)
        
        XCTAssertNoDiff(bankDefaultResponse(in: settings), loadedBankDefault)
    }
    
    func test_mapToSettings_shouldSetBankDefaultWithRequestsLimit() {
        
        let loadedBankDefault = bankDefault(
            .onDisabled,
            requestLimitMessage: anyMessage()
        )
        
        let settings = map(bankDefaultResponse: loadedBankDefault)
        
        XCTAssertNoDiff(bankDefaultResponse(in: settings), loadedBankDefault)
    }
    
    func test_mapToSettings_shouldSetProductSelectorWithEmptyProductsOnEmptyProducts() {
        
        let settings = map(getProductsStub: [])
        
        XCTAssertNoDiff(productSelector(in: settings)?.products, [])
    }
    
    func test_mapToSettings_shouldSetProductSelectorWithProducts() {
        
        let products = [makeProduct(), makeProduct()]
        
        let settings = map(getProductsStub: products)
        
        XCTAssertNoDiff(productSelector(in: settings)?.products, products)
    }
    
    func test_mapToSettings_shouldSetProductSelectorSelectedProductOnMatch() {
        
        let products = [makeProduct(), makeProduct()]
        let contract = paymentContract(accountID: products[1].accountID)
        
        let settings = map(
            getProductsStub: products,
            paymentContract: contract
        )
        
        XCTAssertNoDiff(productSelector(in: settings)?.selectedProduct, products[1])
    }
    
    func test_mapToSettings_shouldSetProductSelectorSelectedProductNilOnNoMatch() {
        
        let products = [makeProduct(), makeProduct()]
        let nonMatch = makeProduct()
        let contract = paymentContract(accountID: nonMatch.accountID)
        
        let settings = map(
            getProductsStub: products,
            paymentContract: contract
        )
        
        XCTAssertNoDiff(productSelector(in: settings)?.selectedProduct, nil)
    }
    
    func test_mapToSettings_shouldSetProductSelectorSelectedProductNilOnEmptyProducts() {
        
        let nonMatch = makeProduct()
        let contract = paymentContract(accountID: nonMatch.accountID)
        
        let settings = map(
            getProductsStub: [],
            paymentContract: contract
        )
        
        XCTAssertNoDiff(productSelector(in: settings)?.selectedProduct, nil)
    }
    
    func test_mapToSettings_shouldSetConsentListStateToCollapsedErrorOnNilConsentEmptyBanks() {
        
        let consent: Consent? = nil
        let settings = map(consent: consent)
        
        XCTAssertNoDiff(consentList(in: settings), .failure(.collapsedError))
    }
    
    func test_mapToSettings_shouldSetConsentListStateToCollapsedErrorOnNilConsentNonEmptyBanks() {
        
        let consent: Consent? = nil
        let settings = map(getBanksStub: [.a], consent: consent)
        
        XCTAssertNoDiff(consentList(in: settings), .failure(.collapsedError))
    }
    
    func test_mapToSettings_shouldSetConsentListStateToEmptyOnEmptyConsentEmptyBanks() {
        
        let consent: Consent? = []
        let settings = map(consent: consent)
        
        XCTAssertNoDiff(consentList(in: settings), .success(.init(banks: [])))
    }
    
    func test_mapToSettings_shouldSetConsentListStateOnEmptyConsentNonEmptyBanks() {
        
        let consent: Consent? = []
        let settings = map(getBanksStub: [.a], consent: consent)
        
        XCTAssertNoDiff(consentList(in: settings), .success(.init(banks: [
            .init(bank: .a, isConsented: false, isSelected: false)
        ])))
    }
    
    func test_mapToSettings_shouldSetConsentListStateOnNonEmptyConsentNonEmptyBanks() {
        
        let consent: Consent? = ["a"]
        let settings = map(getBanksStub: [.a], consent: consent)
        
        XCTAssertNoDiff(consentList(in: settings), .success(.init(banks: [
            .init(bank: .a, isConsented: true, isSelected: true)
        ])))
    }
    
    // MARK: - Helpers
    
    private typealias SUT = MicroServices.GetSettingsMapper
    
    private func makeSUT(
        getProductsStub: [Product] = [],
        getBanksStub: [Bank] = [],
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT(
            getProducts: { getProductsStub },
            getBanks: { getBanksStub }
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func map(
        getProductsStub: [Product] = [],
        getBanksStub: [Bank] = [],
        paymentContract: UserPaymentSettings.PaymentContract = paymentContract(),
        consent: Consent? = nil,
        bankDefaultResponse: UserPaymentSettings.GetBankDefaultResponse = bankDefault(),
        file: StaticString = #file,
        line: UInt = #line
    ) -> UserPaymentSettings {
        
        let sut = makeSUT(
            getProductsStub: getProductsStub,
            getBanksStub: getBanksStub,
            file: file, line: line
        )
        
        return sut.mapToSettings(
            paymentContract: paymentContract,
            consent: consent,
            bankDefaultResponse: bankDefaultResponse
        )
    }
    
    private func details(
        in settings: UserPaymentSettings
    ) -> UserPaymentSettings.Details? {
        
        guard case let .contracted(details) = settings
        else { return nil }
        
        return details
    }
    
    private func contract(
        in settings: UserPaymentSettings
    ) -> UserPaymentSettings.PaymentContract? {
        
        details(in: settings)?.paymentContract
    }
    
    private func consentList(
        in settings: UserPaymentSettings
    ) -> ConsentListState? {
        
        details(in: settings)?.consentList
    }
    
    private func bankDefaultResponse(
        in settings: UserPaymentSettings
    ) -> UserPaymentSettings.GetBankDefaultResponse? {
        
        details(in: settings)?.bankDefaultResponse
    }
    
    private func productSelector(
        in settings: UserPaymentSettings
    ) -> UserPaymentSettings.ProductSelector? {
        
        details(in: settings)?.productSelector
    }
}
