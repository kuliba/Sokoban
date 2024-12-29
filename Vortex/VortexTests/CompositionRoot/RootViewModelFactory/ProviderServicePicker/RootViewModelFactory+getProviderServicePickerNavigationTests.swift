//
//  RootViewModelFactory+getProviderServicePickerNavigationTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 29.12.2024.
//

@testable import Vortex
import XCTest

final class RootViewModelFactory_getProviderServicePickerNavigationTests: RootViewModelFactoryTests {
    
    func test_shouldDeliverFailureOnMissingProduct() {
        
        let (sut, _,_) = makeSUT()
        let exp = expectation(description: "wait for completion")
        
        sut.getProviderServicePickerNavigation(
            select: makeSelect(),
            notify: { _ in }
        ) {
            switch $0 {
            case let .failure(failure):
                XCTAssertNoDiff(failure, .connectivityError)
                
            default:
                XCTFail("Expected failure, but got \($0) instead.")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_shouldDeliverFailureOnHTTPClientFailure() {
        
        let model: Model = .mockWithEmptyExcept()
        model.addSberProduct()
        let (sut, httpClient, _) = makeSUT(model: model)
        let exp = expectation(description: "wait for completion")
        
        sut.getProviderServicePickerNavigation(
            select: makeSelect(),
            notify: { _ in }
        ) {
            switch $0 {
            case let .failure(failure):
                XCTAssertNoDiff(failure, .connectivityError)

            default:
                XCTFail("Expected failure, but got \($0) instead.")
            }
            
            exp.fulfill()
        }
        
        httpClient.complete(with: anyError())
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_shouldDeliverFailureOnHTTPClientServerError() {
        
        let model: Model = .mockWithEmptyExcept()
        model.addSberProduct()
        let (sut, httpClient, _) = makeSUT(model: model)
        let exp = expectation(description: "wait for completion")
        
        sut.getProviderServicePickerNavigation(
            select: makeSelect(),
            notify: { _ in }
        ) {
            switch $0 {
            case let .failure(failure):
                XCTAssertNoDiff(failure, .serverError("Возникла техническая ошибка"))

            default:
                XCTFail("Expected failure, but got \($0) instead.")
            }
            
            exp.fulfill()
        }
        
        httpClient.complete(withString: .serverErrorJSON)
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_shouldDeliverSuccessOnHTTPClientSuccess() {
        
        let model: Model = .mockWithEmptyExcept()
        model.addSberProduct()
        let (sut, httpClient, _) = makeSUT(model: model)
        let exp = expectation(description: "wait for completion")
        
        sut.getProviderServicePickerNavigation(
            select: makeSelect(),
            notify: { _ in }
        ) {
            switch $0 {
            case .ok:
                break

            default:
                XCTFail("Expected success, but got \($0) instead.")
            }
            
            exp.fulfill()
        }
        
        httpClient.complete(withString: .createAnywayTransferIsNewPaymentTrueResponse)
        
        wait(for: [exp], timeout: 1.0)
    }
    
    // MARK: - Helpers
    
    private typealias Domain = ProviderServicePickerDomain
    private typealias Select = Domain.Select
    private typealias NotifySpy = CallSpy<Domain.NotifyEvent, Void>
    
    private func makeSelect(
        service: UtilityService? = nil,
        isOneOf: Bool = .random(),
        operator: UtilityPaymentOperator? = nil
    ) -> Select {
        
        return .init(
            item: .init(
                service: service ?? makeUtilityService(),
                isOneOf: isOneOf
            ),
            operator: `operator` ?? makeUtilityPaymentOperator()
        )
    }
}

extension String {
    
    static let serverErrorJSON = """
{
    "statusCode": 102,
    "errorMessage": "Возникла техническая ошибка",
    "data": null
}
"""
}
