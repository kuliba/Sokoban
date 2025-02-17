//
//  RootViewModelFactory+GetSavingsAccountNavigationTests.swift
//  VortexTests
//
//  Created by Andryusina Nataly on 09.12.2024.
//

import CombineSchedulers
@testable import Vortex
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
    
    func test_getNavigation_shouldDeliverOpenSavingsAccountOnOpenSavingsAccount() {
        
        getNavigation(with: .openSavingsAccount) {
            
            switch $0 {
            case .openSavingsAccount:
                break
                
            default:
                XCTFail("Expected order, got \($0) instead.")
            }
        }
    }
    
    // MARK: - Helpers
    
    private typealias Domain = SavingsAccountDomain
    private typealias SUT = RootViewModelFactory
    
    // TODO: improve tests with QR result assertions
    private func makeSUT(
        mapScanResult: @escaping SUT.MapScanResult = { _, completion in completion(.unknown) },
        makeQRResolve: @escaping SUT.MakeResolveQR = { _ in { _ in .unknown }},
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT(
            model: .mockWithEmptyExcept(),
            httpClient: HTTPClientSpy(),
            logger: LoggerSpy(),
            mapScanResult: mapScanResult,
            makeQRResolve: makeQRResolve,
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
