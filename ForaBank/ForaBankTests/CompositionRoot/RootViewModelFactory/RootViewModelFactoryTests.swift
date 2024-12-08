//
//  RootViewModelFactoryTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 21.10.2024.
//

@testable import Vortex
import PayHubUI
import XCTest

class RootViewModelFactoryTests: QRNavigationTests {
    
    typealias SUT = RootViewModelFactory
    
    func makeSUT(
        scanResult: QRModelResult = .unknown,
        model: Model = .mockWithEmptyExcept(),
        scanner: QRScannerViewModel = QRScannerViewModelSpy(),
        schedulers: Schedulers = .immediate,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        httpClient: HTTPClientSpy,
        logger: LoggerSpy
    ) {
        let httpClient = HTTPClientSpy()
        let logger = LoggerSpy() // TODO: add logging tests
        let sut = SUT(
            model: model,
            httpClient: httpClient,
            logger: logger,
            mapScanResult: { _, completion in completion(scanResult) },
            resolveQR: { _ in .unknown },
            scanner: scanner,
            schedulers: schedulers
        )
        
        // factory is captured by long-running closures
        //    trackForMemoryLeaks(sut, file: file, line: line)
        //    trackForMemoryLeaks(model, file: file, line: line)
        //    trackForMemoryLeaks(httpClient, file: file, line: line)
        //    trackForMemoryLeaks(logger, file: file, line: line)
        
        return (sut, httpClient, logger)
    }
}
