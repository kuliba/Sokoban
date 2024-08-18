//
//  QRFlowEffectHandlerTests.swift
//
//
//  Created by Igor Malyarov on 18.08.2024.
//

enum QRFlowEvent: Equatable {}

enum QRFlowEffect<ScanResult> {
    
    case processScanResult(ScanResult)
}

extension QRFlowEffect: Equatable where ScanResult: Equatable {}

struct QRFlowEffectHandlerMicroServices<ScanResult> {
    
    let processScanResult: ProcessScanResult
}

extension QRFlowEffectHandlerMicroServices {
    
    typealias ProcessScanResultCompletion = (()) -> Void
    typealias ProcessScanResult = (ScanResult, @escaping ProcessScanResultCompletion) -> Void
}

final class QRFlowEffectHandler<ScanResult> {
    
    private let microServices: MicroServices
    
    init(
        microServices: MicroServices
    ) {
        self.microServices = microServices
    }
    
    typealias MicroServices = QRFlowEffectHandlerMicroServices<ScanResult>
}

extension QRFlowEffectHandler {
    
    func handleEffect(
        _ effect: Effect,
        _ dispatch: @escaping Dispatch
    ) {
        switch effect {
        case let .processScanResult(scanResult):
            microServices.processScanResult(scanResult) { _ in }
        }
    }
}

extension QRFlowEffectHandler {
    
    typealias Dispatch = (Event) -> Void
    
    typealias Event = QRFlowEvent
    typealias Effect = QRFlowEffect<ScanResult>
}


import XCTest

final class QRFlowEffectHandlerTests: XCTestCase {
    
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
    
    // MARK: - Helpers
    
    private typealias SUT = QRFlowEffectHandler<ScanResult>
    private typealias ProcessScanResultSpy = Spy<ScanResult, Void>
    
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
    
    private struct ScanResult: Equatable {
        
        let value: String
    }
    
    private func makeScanResult(
        _ value: String = anyMessage()
    ) -> ScanResult {
        
        return .init(value: value)
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
