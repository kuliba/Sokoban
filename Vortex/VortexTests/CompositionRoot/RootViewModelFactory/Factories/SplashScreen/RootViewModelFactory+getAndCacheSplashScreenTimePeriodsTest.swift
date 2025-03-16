//
//  RootViewModelFactory+getAndCacheSplashScreenTimePeriodsTest.swift
//  VortexTests
//
//  Created by Igor Malyarov on 15.03.2025.
//

@testable import Vortex
import XCTest

final class RootViewModelFactory_getAndCacheSplashScreenTimePeriodsTest: RootViewModelFactoryTests {
    
    func test_scheduleGetAndCacheSplashScreenTimePeriods_shouldCallHTTPClient() {
        
        let (sut, httpClient, _) = makeSUT()
        
        sut.scheduleGetAndCacheSplashScreenTimePeriods()
        
        self.awaitActorThreadHop()
        httpClient.complete(with: anyError())
        
        httpClient.expectRequests(withLastPathComponents: [
            "getSplashScreenTimePeriods"
        ])
    }
    
    // MARK: - getAndCacheSplashScreenTimePeriods
    
    func test_getAndCacheSplashScreenTimePeriods_shouldCallHTTPClient() {
        
        let (sut, httpClient, _) = makeSUT()
        
        getAndCacheSplashScreenTimePeriods(sut: sut) {
            
            self.awaitActorThreadHop()
            httpClient.complete(with: anyError())
        }
        
        httpClient.expectRequests(withLastPathComponents: [
            "getSplashScreenTimePeriods"
        ])
    }
    
    func test_getAndCacheSplashScreenTimePeriods_shouldCompleteWithFalse_onMissingCacheAndRemoteFailure() {
        
        let (sut, httpClient, _) = makeSUT()
        
        getAndCacheSplashScreenTimePeriods(sut: sut, assert: { XCTAssertFalse($0) }) {
            
            self.awaitActorThreadHop()
            httpClient.complete(with: anyError())
        }
        
        httpClient.expectRequests(withLastPathComponents: [
            "getSplashScreenTimePeriods"
        ])
    }
    
    // MARK: - Helpers
    
    private func getAndCacheSplashScreenTimePeriods(
        sut: SUT,
        assert: @escaping (Bool) -> Void = { _ in },
        on action: () -> Void,
        timeout: TimeInterval = 1.0
    ) {
        let exp = expectation(description: "wait for completion")
        
        sut.getAndCacheSplashScreenTimePeriods {
            
            assert($0)
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
}
