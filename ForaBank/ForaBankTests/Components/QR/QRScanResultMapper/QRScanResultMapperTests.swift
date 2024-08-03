//
//  QRScanResultMapperTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 03.08.2024.
//

@testable import ForaBank
import XCTest

final class QRScanResultMapperTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborator() {
        
        let (sut, spy) = makeSUT()
        
        XCTAssertEqual(spy.callCount, 0)
        XCTAssertNotNil(sut)
    }
    
    func test_mapScanResult_shouldDeliverFailureOnQRWithMissingQRMapping() {
        
        let qr = anyQR()
        let (sut, spy) = makeSUT(qrMapping: nil)
        
        expect(sut, with: .qrCode(qr), delivers: .failure(qr), on: {})
        XCTAssertEqual(spy.callCount, 0)
    }
    
    func test_mapScanResult_shouldDeliverC2BURLOnC2BURL() {
        
        let url = anyURL()
        let (sut, spy) = makeSUT()
        
        expect(sut, with: .c2bURL(url), delivers: .c2bURL(url), on: {})
        XCTAssertEqual(spy.callCount, 0)
    }
    
    func test_mapScanResult_shouldDeliverC2BSubscribeURLOnC2BSubscribeURL() {
        
        let url = anyURL()
        let (sut, spy) = makeSUT()
        
        expect(sut, with: .c2bSubscribeURL(url), delivers: .c2bSubscribeURL(url), on: {})
        XCTAssertEqual(spy.callCount, 0)
    }
    
    func test_mapScanResult_shouldDeliverSberQROnSberQR() {
        
        let sberQR = anyURL()
        let (sut, spy) = makeSUT()
        
        expect(sut, with: .sberQR(sberQR), delivers: .sberQR(sberQR), on: {})
        XCTAssertEqual(spy.callCount, 0)
    }
    
    func test_mapScanResult_shouldDeliverURLOnURL() {
        
        let url = anyURL()
        let (sut, spy) = makeSUT()
        
        expect(sut, with: .url(url), delivers: .url(url), on: {})
        XCTAssertEqual(spy.callCount, 0)
    }
    
    func test_mapScanResult_shouldDeliverUnknownOnUnknown() {
        
        let (sut, spy) = makeSUT()
        
        expect(sut, with: .unknown, delivers: .unknown, on: {})
        XCTAssertEqual(spy.callCount, 0)
    }
    
    // MARK: - Helpers
    
    private typealias SUT = QRScanResultMapper
    private typealias LoadResult = SUT.MicroServices.LoadResult
    private typealias GetOperatorsSpy = Spy<(QRCode, QRMapping), LoadResult, Never>
    private typealias ScanResult = QRViewModel.ScanResult
    
    private func makeSUT(
        qrMapping: QRMapping? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        spy: GetOperatorsSpy
    ) {
        let spy = GetOperatorsSpy()
        let sut = SUT(
            microServices: .init(
                getMapping: { return qrMapping },
                getOperators: { spy.process(($0, $1), completion: $2) }
            )
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        
        return (sut, spy)
    }
    
    private func anyQR(
        original: String = anyMessage(),
        rawData: [String: String] = [anyMessage(): anyMessage()]
    ) -> QRCode {
        
        return .init(original: original, rawData: rawData)
    }
    
    private func expect(
        _ sut: SUT,
        with scanResult: ScanResult,
        delivers expectedResult: QRModelResult,
        timeout: TimeInterval = 0.05,
        on action: () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "wait for completion")
        
        sut.mapScanResult(scanResult) { receivedResult in
            
            XCTAssertNoDiff(receivedResult, expectedResult, "Expected \(expectedResult), but got \(receivedResult) instead.")
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: timeout)
    }
}
