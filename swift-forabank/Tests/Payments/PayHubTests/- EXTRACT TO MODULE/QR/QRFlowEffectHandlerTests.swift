//
//  QRFlowEffectHandlerTests.swift
//
//
//  Created by Igor Malyarov on 18.08.2024.
//

import XCTest

final class QRFlowEffectHandlerTests: QRFlowTests {
    
    // MARK: - init
    
    func test_shouldNotCallCollaborators() {
        
        let (_, processScanResult) = makeSUT()
        
        XCTAssertEqual(processScanResult.callCount, 0)
    }
    
    // MARK: - processScanResult
    
    func test_processScanResult_shouldCallProcessScanResultWithPayload() {
        
        let scanResult = makeScanResult()
        let (sut, processScanResult) = makeSUT()
        
        sut.handleEffect(.processScanResult(scanResult)) { _ in }
        
        XCTAssertNoDiff(processScanResult.payloads, [scanResult])
    }
    
    func test_processScanResult_shouldDeliverDestination() {
    
        let destination = makeDestination()
        let (sut, processScanResult) = makeSUT()
        
        expect(sut, with: .processScanResult(makeScanResult()), toDeliver: .destination(destination)) {
            
            processScanResult.complete(with: destination)
        }
    }
    
    // MARK: - Helpers
    
    private typealias SUT = QRFlowEffectHandler<Destination, ScanResult>
    private typealias ProcessScanResultSpy = Spy<ScanResult, Destination>
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        processScanResult: ProcessScanResultSpy
    ) {
        let processScanResult = ProcessScanResultSpy()
        let sut = SUT(microServices: .init(
            processScanResult: processScanResult.process
        ))
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(processScanResult, file: file, line: line)
        
        return (sut, processScanResult)
    }
    
    private func expect(
        _ sut: SUT? = nil,
        with effect: SUT.Effect,
        toDeliver expectedEvents: SUT.Event...,
        on action: @escaping () -> Void = {},
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let sut = sut ?? makeSUT().sut
        let exp = expectation(description: "wait for completion")
        exp.expectedFulfillmentCount = expectedEvents.count
        var receivedEvents = [SUT.Event]()
        
        sut.handleEffect(effect) {
            
            receivedEvents.append($0)
            exp.fulfill()
        }
        
        action()
        
        XCTAssertNoDiff(receivedEvents, expectedEvents, file: file, line: line)
        
        wait(for: [exp], timeout: 1)
    }
}
