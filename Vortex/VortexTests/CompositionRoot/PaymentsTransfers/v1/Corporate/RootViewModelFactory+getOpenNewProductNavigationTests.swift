//
//  RootViewModelFactory+getOpenNewProductNavigationTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 30.01.2025.
//

@testable import Vortex
import XCTest

final class RootViewModelFactory_getOpenNewProductNavigationTests: RootViewModelFactoryTests {
    
    // MARK: - productType
    
    func test_accountProductType_shouldDeliverFailureAlert() {
        
        expect(.productType(.account), toDeliver: .alert("Ошибка открытия счета."))
    }
    
    func test_accountProductType_shouldDeliverOpenAccount() {
        
        let model = makeModelWithOpenAccount()
        let sut = makeSUT(model: model).sut
        
        expect(sut: sut, .productType(.account), toDeliver: .openAccount)
    }
    
    func test_cardProductType_shouldDeliverOpenCard() {
        
        expect(.productType(.card), toDeliver: .openCard)
    }
    
    func test_depositProductType_shouldDeliverOpenDeposit() {
        
        expect(.productType(.deposit), toDeliver: .openDeposit)
    }
    
    // MARK: - openProduct
    
    func test_openProduct_shouldDeliverOpenProduct() {
        
        expect(.openProduct, toDeliver: .openProduct)
    }
    
    // MARK: - Helpers
    
    private typealias Domain = Vortex.OpenProductDomain
    
    private func makeSuccess() -> Node<PaymentsSuccessViewModel> {
        
        return .init(
            model: .init(
                model: .mockWithEmptyExcept(),
                sections: []
            ),
            cancellables: []
        )
    }
    
    private func makeModelWithMeToMeProduct(
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> Model {
        
        let model: Model = .mockWithEmptyExcept()
        try model.addMeToMeProduct(file: file, line: line)
        
        return model
    }
    
    private func expect(
        featureFlags: FeatureFlags = .active,
        sut: SUT? = nil,
        _ select: Domain.Select,
        toDeliver expectedNavigation: EquatableNavigation,
        timeout: TimeInterval = 1.0,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let sut = sut ?? makeSUT().sut
        let exp = expectation(description: "wait for get navigation completion")
        
        sut.getNavigation(
            featureFlags: featureFlags,
            select: select,
            notify: { _ in }
        ) {
            XCTAssertNoDiff(self.equatable($0), expectedNavigation, "Expected \(expectedNavigation), but got \($0) instead.", file: file, line: line)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: timeout)
    }
    
    private func equatable(
        _ navigation: Domain.Navigation
    ) -> EquatableNavigation {
        
        switch navigation {
        case let .alert(alert):
            return .alert(alert)
            
        case .openAccount:
            return .openAccount
            
        case .openCard:
            return .openCard
            
        case .openDeposit:
            return .openDeposit
            
        case .openProduct:
            return .openProduct
            
        case let .openURL(url):
            return .openURL(url)
        }
    }
    
    // TODO: improve, but need to control objects creation => SUT needs a dependency
    enum EquatableNavigation: Equatable {
        
        case alert(String)
        case openAccount
        case openCard
        case openDeposit
        case openProduct
        case openURL(URL)
    }
}

extension XCTestCase {
    
    func makeModelWithOpenAccount() -> Model {
        
        let model = Model.mockWithEmptyExcept()
        model.currencyList.value = [.rub]
        model.accountProductsList.value = [.stub]
        
        return model
    }
}

extension OpenAccountProductData {
    
    static let stub: Self = .init(currencyAccount: anyMessage(), open: true, breakdownAccount: anyMessage(), accountType: anyMessage(), currencyCode: 643, currency: .rub, designMd5hash: anyMessage(), designSmallMd5hash: anyMessage(), detailedConditionUrl: anyMessage(), detailedRatesUrl: anyMessage(), txtConditionList: [])
}

