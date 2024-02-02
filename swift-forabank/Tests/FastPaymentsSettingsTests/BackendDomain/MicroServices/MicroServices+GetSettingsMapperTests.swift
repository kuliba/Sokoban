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
        
        let product = makeProduct()
        let loadedContract = paymentContract(productID: product.id)
        
        let settings = map(
            getProductsStub: [product],
            paymentContract: loadedContract
        )
        
        XCTAssertNoDiff(contract(in: settings), loadedContract)
    }
    
    func test_mapToSettings_shouldSetConsentListSuccess() {
        
        let product = makeProduct()
        let consent: Consent = .preview
        let loadedConsentList = consentListSuccess(FastPaymentsSettingsTests.consentList(consent: consent))
        
        let settings = map(
            getProductsStub: [product],
            consent: consent
        )
        
        XCTAssertNoDiff(consentList(in: settings), loadedConsentList)
    }
    
    func test_mapToSettings_shouldSetConsentListFailure() {
        
        let product = makeProduct()
        let consent: Consent = .preview
        let loadedConsentList = consentListSuccess(FastPaymentsSettingsTests.consentList(consent: consent))

        let settings = map(
            getProductsStub: [product],
            consent: consent
        )
        
        XCTAssertNoDiff(consentList(in: settings), loadedConsentList)
    }
    
    func test_mapToSettings_shouldSetBankDefault() {
        
        let product = makeProduct()
        let loadedBankDefault = bankDefault(.onDisabled)
        
        let settings = map(
            getProductsStub: [product],
            bankDefaultResponse: loadedBankDefault
        )
        
        XCTAssertNoDiff(bankDefaultResponse(in: settings), loadedBankDefault)
    }
    
    func test_mapToSettings_shouldSetBankDefaultWithRequestsLimit() {
        
        let product = makeProduct()
        let loadedBankDefault = bankDefault(
            .onDisabled,
            requestLimitMessage: anyMessage()
        )
        
        let settings = map(
            getProductsStub: [product],
            bankDefaultResponse: loadedBankDefault
        )
        
        XCTAssertNoDiff(bankDefaultResponse(in: settings), loadedBankDefault)
    }
    
    func test_mapToSettings_shouldSetProductSelectorWithEmptyProducts() {
        
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
        let contract = paymentContract(productID: products[1].id)
        
        let settings = map(
            getProductsStub: products,
            paymentContract: contract
        )
        
        XCTAssertNoDiff(productSelector(in: settings)?.selectedProduct, products[1])
    }
    
    func test_mapToSettings_shouldSetProductSelectorSelectedProductNilOnNoMatch() {
        
        let products = [makeProduct(), makeProduct()]
        let nonMatch = makeProduct()
        let contract = paymentContract(productID: nonMatch.id)
        
        let settings = map(
            getProductsStub: products,
            paymentContract: contract
        )
        
        XCTAssertNoDiff(productSelector(in: settings)?.selectedProduct, nil)
    }
    
    func test_mapToSettings_shouldSetProductSelectorSelectedProductNilOnEmptyProducts() {
        
        let nonMatch = makeProduct()
        let contract = paymentContract(productID: nonMatch.id)
        
        let settings = map(
            getProductsStub: [],
            paymentContract: contract
        )
        
        XCTAssertNoDiff(productSelector(in: settings)?.selectedProduct, nil)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = MicroServices.GetSettingsMapper
    
    private func makeSUT(
        getProductsStub: [Product],
        getSelectableBanksStub: [ConsentList.SelectableBank] = [],
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT(
            getProducts: { getProductsStub },
            getSelectableBanks: { getSelectableBanksStub }
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func map(
        getProductsStub: [Product],
        paymentContract: UserPaymentSettings.PaymentContract = paymentContract(),
        consent: Consent = .preview,
        bankDefaultResponse: UserPaymentSettings.GetBankDefaultResponse = bankDefault(),
        file: StaticString = #file,
        line: UInt = #line
    ) -> UserPaymentSettings {
        
        let sut = makeSUT(getProductsStub: getProductsStub, file: file, line: line)
        
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
