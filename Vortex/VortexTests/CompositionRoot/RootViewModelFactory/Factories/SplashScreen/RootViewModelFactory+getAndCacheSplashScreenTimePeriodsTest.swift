//
//  RootViewModelFactory+getAndCacheSplashScreenTimePeriodsTest.swift
//  VortexTests
//
//  Created by Igor Malyarov on 15.03.2025.
//

@testable import Vortex
import XCTest

final class RootViewModelFactory_getAndCacheSplashScreenTimePeriodsTest: SplashScreenRootViewModelFactoryTests {
    
    func test_scheduleGetAndCacheSplashScreenTimePeriods_shouldCallHTTPClient() {
        
        let (sut, httpClient, _) = makeSUT()
        
        sut.scheduleGetAndCacheSplashScreenTimePeriods()
        
        self.awaitActorThreadHop()
        httpClient.complete(with: anyError())
        
        httpClient.expectRequests(withLastPathComponents: [
            "getSplashScreenTimePeriods"
        ])
    }
    
    func test_scheduleGetAndCacheSplashScreenTimePeriods_shouldNotClearSplashImagesCache_onMissingCacheAndRemoteFailure() {
        
        let (sut, httpClient, logger) = makeSUT()
        
        sut.scheduleGetAndCacheSplashScreenTimePeriods()
        
        self.awaitActorThreadHop()
        httpClient.complete(with: anyError())
        
        XCTAssertNoDiff(logger.cacheEvent, [])
    }
    
    func test_scheduleGetAndCacheSplashScreenTimePeriods_shouldClearSplashImagesCache_onMissingCacheAndRemoteSuccess() {
        
        let (sut, httpClient, logger) = makeSUT()
        
        sut.scheduleGetAndCacheSplashScreenTimePeriods()
        
        self.awaitActorThreadHop()
        try? httpClient.complete(with: periods())
        self.awaitActorThreadHop()

        XCTAssertNoDiff(logger.cacheEvent.map(\.message), ["Cleared SplashImages cache."])
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
    }
    
    func test_getAndCacheSplashScreenTimePeriods_shouldCompleteWithFalse_onEmptyCacheAndRemoteFailure() {
        
        let (sut, httpClient, _) = makeSUT(
            model: .mockWithEmptyExcept(localAgent: LocalAgentMock(values: []))
        )
        
        getAndCacheSplashScreenTimePeriods(sut: sut, assert: { XCTAssertFalse($0) }) {
            
            self.awaitActorThreadHop()
            httpClient.complete(with: anyError())
        }
    }
    
    func test_getAndCacheSplashScreenTimePeriods_shouldCompleteWithFalse_onNonEmptyCacheAndRemoteFailure() throws {
        
        let (sut, httpClient, _) = makeSUT(model: modelWithCachedPeriods())
        
        getAndCacheSplashScreenTimePeriods(sut: sut, assert: { XCTAssertFalse($0) }) {
            
            self.awaitActorThreadHop()
            httpClient.complete(with: anyError())
        }
    }
    
    func test_getAndCacheSplashScreenTimePeriods_shouldCompleteWithTrue_onMissingCacheAndRemoteSuccess() {
        
        let (sut, httpClient, _) = makeSUT()
        
        getAndCacheSplashScreenTimePeriods(sut: sut, assert: { XCTAssertTrue($0) }) {
            
            self.awaitActorThreadHop()
            try? httpClient.complete(with: periods())
        }
    }
    
    func test_getAndCacheSplashScreenTimePeriods_shouldCompleteWithTrue_onNonEmptyCacheAndRemoteSuccessWithDifferentSerial() throws {
        
        let (sut, httpClient, _) = makeSUT(model: modelWithCachedPeriods())
        
        getAndCacheSplashScreenTimePeriods(sut: sut, assert: { XCTAssertTrue($0) }) {
            
            self.awaitActorThreadHop()
            try? httpClient.complete(with: periods())
        }
    }
    
    func test_getAndCacheSplashScreenTimePeriods_shouldCompleteWithFalse_onNonEmptyCacheAndRemoteSuccessWithSameSerial() throws {
        
        let (sut, httpClient, _) = makeSUT(model: modelWithCachedPeriods(
            serial: "4bc2481fb8b6661e210b85462b954d05"
        ))
        
        getAndCacheSplashScreenTimePeriods(sut: sut, assert: { XCTAssertFalse($0) }) {
            
            self.awaitActorThreadHop()
            try? httpClient.complete(with: periods())
        }
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
    
    private func periods() throws -> Data {
        
        return try XCTUnwrap(Data(String.periodsResponse.utf8))
    }
    
    private func modelWithCachedPeriods(
        period: CodableSplashScreenTimePeriod? = nil,
        serial: String? = nil
    ) -> Model {
        
        let periods = period ?? makeCodableSplashScreenTimePeriod()
        let localAgent = LocalAgentMock(stubs: [([periods], serial)])
        
        return .mockWithEmptyExcept(localAgent: localAgent)
    }
    
    private func makeCodableSplashScreenTimePeriod(
        timePeriod: String = anyMessage(),
        startTime: String = anyMessage(),
        endTime: String = anyMessage()
    ) -> CodableSplashScreenTimePeriod {
        
        return .init(timePeriod: timePeriod, startTime: startTime, endTime: endTime)
    }
}

private extension String {
    
    static let periodsResponse = """
{
  "statusCode": 0,
  "errorMessage": null,
  "data": {
    "serial": "4bc2481fb8b6661e210b85462b954d05",
    "splashScreenTimePeriods": [
      {
        "timePeriod": "NIGHT",
        "startTime": "00:00",
        "endTime": "03:59"
      }
    ]
  }
}
"""
}
