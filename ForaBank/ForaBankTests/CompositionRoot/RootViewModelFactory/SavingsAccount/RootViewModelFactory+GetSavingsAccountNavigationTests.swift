//
//  RootViewModelFactory+GetSavingsAccountNavigationTests.swift
//  ForaBankTests
//
//  Created by Andryusina Nataly on 09.12.2024.
//

import CombineSchedulers
@testable import ForaBank
import XCTest

final class RootViewModelFactory_GetSavingsAccountNavigationTests: XCTestCase {
    
    // MARK: - getNavigation
    
    func test_getNavigation_shouldDeliverMainOnGoToMain() {
        
        getNavigation(with: .goToMain) {
            
            switch $0 {
            case .main:
                break
                
            default:
                XCTFail("Expected main, got \($0) instead.")
            }
        }
    }
    
    func test_getNavigation_shouldDeliverOrderOnOrder() {
        
        getNavigation(with: .order) {
            
            switch $0 {
            case .order:
                break
                
            default:
                XCTFail("Expected order, got \($0) instead.")
            }
        }
    }
    
    // MARK: - Helpers
    
    private typealias Domain = SavingsAccountDomain
    private typealias SUT = RootViewModelFactory
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT(
            model: .mockWithEmptyExcept(),
            httpClient: HTTPClientSpy(),
            logger: LoggerSpy(),
            mapScanResult: { _, completion in completion(.unknown) },
            resolveQR: { _ in .unknown },
            scanner: QRScannerViewModelSpy(),
            schedulers: .immediate
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func getNavigation(
        _ sut: SUT? = nil,
        with select: Domain.Select,
        notify: @escaping Domain.Notify = { _ in },
        completion: @escaping (Domain.Navigation) -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        
        let sut = sut ?? makeSUT(file: file, line: line)
        let exp = expectation(description: "wait for completion")
        
        sut.getSavingsAccountNavigation(select: select, notify: notify) {
            
            completion($0)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
    }
}
