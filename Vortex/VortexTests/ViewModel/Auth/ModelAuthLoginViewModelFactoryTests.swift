//
//  ModelAuthLoginViewModelFactoryTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 14.09.2023.
//

@testable import Vortex
import XCTest

final class ModelAuthLoginViewModelFactoryTests: XCTestCase {
    
    // MARK: - makeAuthConfirmViewModel
    
    func test_makeAuthConfirmViewModel() {
        
        let (sut, factory) = makeSUT()
        let confirmCodeLength = 123
        let phoneNumber = "123-4567"
        let resendCodeDelay = 1.0
        let rootActions = RootViewModel.RootActions.emptyMock
        
        let authConfirmViewModel = factory.makeAuthConfirmViewModel(
            confirmCodeLength: confirmCodeLength,
            phoneNumber: phoneNumber,
            resendCodeDelay: resendCodeDelay,
            backAction: {}
        )
        
        XCTAssertEqual(
            authConfirmViewModel.code.codeLenght,
            confirmCodeLength
        )
        XCTAssertNotNil(sut)
    }
    
    // MARK: - makeAuthProductsViewModel
    
    func test_makeAuthProductsViewModel_shouldMakeViewModelWithEmptyProdutCardsOnEmptyCatalogProducts() {
        
        let (sut, factory) = makeSUT()
        
        let authProductsViewModel = factory.makeAuthProductsViewModel(
            action: { _ in },
            dismissAction: {}
        )
        
        XCTAssertTrue(authProductsViewModel.productCards.isEmpty)
        XCTAssertTrue(sut.catalogProducts.value.isEmpty)
    }
    
    func test_makeAuthProductsViewModel_shouldMakeViewModelWithProductCard() {
        
        let (sut, factory) = makeSUT()
        sut.catalogProducts.value = [.sample]
        
        let authProductsViewModel = factory.makeAuthProductsViewModel(
            action: { _ in },
            dismissAction: {}
        )
        
        XCTAssertNoDiff(
            authProductsViewModel.productCards.map(\.title),
            sut.catalogProducts.value.map(\.name)
        )
    }
    
    // MARK: - makeOrderProductViewModel
    
    func test_makeOrderProductViewModel() {
        
        let (sut, factory) = makeSUT()
        
        let orderProductViewModel = factory.makeOrderProductViewModel(
            productData: .sample
        )
        
        XCTAssertNotNil(orderProductViewModel)
        XCTAssertNotNil(sut)
    }
    
    // MARK: - makeCardLandingViewModel
    
    func test_makeOrderProductViewModel_orderCard() {
        
        let (sut, factory) = makeSUT()
        
        let landingViewModel = factory.makeCardLandingViewModel(
            .orderCard,
            config: .default,
            landingActions: { _ in
                return {}
            }
        )
            
            XCTAssertNotNil(landingViewModel)
            XCTAssertNotNil(sut)
    }
    
    func test_makeOrderProductViewModel_transfer() {
        
        let (sut, factory) = makeSUT()
        
        let landingViewModel = factory.makeCardLandingViewModel(
            .transfer,
            config: .default,
            landingActions: { _ in
                return {}
            }
        )
        
        XCTAssertNotNil(landingViewModel)
        XCTAssertNotNil(sut)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        rootActions: RootViewModel.RootActions = .emptyMock,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: Model,
        factory: AuthLoginViewModelFactory
    ) {
        let sut: Model = .mockWithEmptyExcept()
        let factory = sut.authLoginViewModelFactory(
            rootActions: rootActions
        )
        
        // TODO: restore memory leaks tracking after Model fix
        // trackForMemoryLeaks(sut, file: file, line: line)
        // trackForMemoryLeaks(factory, file: file, line: line)
        
        return (sut, factory)
    }
}
