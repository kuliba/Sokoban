//
//  MicroServices+GetSettingsMapperTests.swift
//
//
//  Created by Igor Malyarov on 26.01.2024.
//

public extension MicroServices {
    
    final class GetSettingsMapper {
        
#warning("getProducts should employ this requirements for products attributes https://www.figma.com/file/BYCudUIJc4iYr8Ngaorg0Y/10.-%D0%9F%D1%80%D0%BE%D1%84%D0%B8%D0%BB%D1%8C-%D0%BF%D0%BE%D0%BB%D1%8C%D0%B7%D0%BE%D0%B2%D0%B0%D1%82%D0%B5%D0%BB%D1%8F.-%D0%9D%D0%B0%D1%81%D1%82%D1%80%D0%BE%D0%B9%D0%BA%D0%B8-%D0%A1%D0%91%D0%9F?type=whiteboard&node-id=1150-24599&t=N2MxHOWGDL4bt3IB-4")
#warning("getProducts is expected to sort products in order that would taking first that is `active` and `main`")
        
        private let getProducts: GetProducts
        
        init(getProducts: @escaping GetProducts) {
            
            self.getProducts = getProducts
        }
    }
}

public extension MicroServices.GetSettingsMapper {
    
    func mapToSettings(
        paymentContract: UserPaymentSettings.PaymentContract,
        consentList: ConsentListState,
        bankDefaultResponse: UserPaymentSettings.GetBankDefaultResponse
    ) -> UserPaymentSettings {
        
        let accountID = paymentContract.productID
        let products = getProducts()
        let selectedProduct = products.first { $0.id == accountID }
        
        let productSelector = UserPaymentSettings.ProductSelector(
            selectedProduct: selectedProduct,
            products: products,
            status: .collapsed
        )
        
        let details = UserPaymentSettings.ContractDetails(
            paymentContract: paymentContract,
            consentList: consentList,
            bankDefaultResponse: bankDefaultResponse,
            productSelector: productSelector
        )
        
        return .contracted(details)
    }
}

public extension MicroServices.GetSettingsMapper {
    
    typealias GetProducts = () -> [Product]
}

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
        let loadedConsentList = consentListSuccess()
        
        let settings = map(
            getProductsStub: [product],
            consentList: loadedConsentList
        )
        
        XCTAssertNoDiff(consentList(in: settings), loadedConsentList)
    }
    
    func test_mapToSettings_shouldSetConsentListFailure() {
        
        let product = makeProduct()
        let loadedConsentList = consentListFailure()
        
        let settings = map(
            getProductsStub: [product],
            consentList: loadedConsentList
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
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT(getProducts: { getProductsStub })
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func map(
        getProductsStub: [Product],
        paymentContract: UserPaymentSettings.PaymentContract = paymentContract(),
        consentList: ConsentListState = consentListSuccess(),
        bankDefaultResponse: UserPaymentSettings.GetBankDefaultResponse = bankDefault(),
        file: StaticString = #file,
        line: UInt = #line
    ) -> UserPaymentSettings {
        
        let sut = makeSUT(getProductsStub: getProductsStub, file: file, line: line)
        
        return sut.mapToSettings(
            paymentContract: paymentContract,
            consentList: consentList,
            bankDefaultResponse: bankDefaultResponse
        )
    }
    
    private func details(
        in settings: UserPaymentSettings
    ) -> UserPaymentSettings.ContractDetails? {
        
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
