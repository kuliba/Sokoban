//
//  QRModelWrapperTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 31.07.2024.
//

@testable import ForaBank
import XCTest

final class QRModelWrapperTests: XCTestCase {
    
    func test_init_shouldNotCallCollaborator() {
        
        let (sut, spy) = makeSUT()
        
        XCTAssertEqual(spy.callCount, 0)
        XCTAssertNotNil(sut)
    }
    
    func test_scanResult_shouldCallHandlerWithScanResult() {
        
        let scanResult: QRViewModel.ScanResult = .c2bURL(anyURL())
        let result = QRViewModelAction.Result(result: scanResult)
        let (sut, spy) = makeSUT(scanResult: scanResult)
        
        sut.qrModel.action.send(result)
        
        XCTAssertNoDiff(spy.payloads, [scanResult])
    }
    
    func test_scanResult_shouldSetStateToInflight() {
        
        let scanResult: QRViewModel.ScanResult = .c2bURL(anyURL())
        let result = QRViewModelAction.Result(result: scanResult)
        let (sut, _) = makeSUT(scanResult: scanResult)
        let stateSpy = ValueSpy(sut.$state)
        
        sut.qrModel.action.send(result)
        
        XCTAssertNoDiff(stateSpy.values, [nil, .inflight])
    }
    
    func test_scanResult_shouldDeliverResult() {
        
        let scanResult: QRViewModel.ScanResult = .c2bURL(anyURL())
        let result = QRViewModelAction.Result(result: scanResult)
        let qrResult = anyMessage()
        let (sut, spy) = makeSUT(scanResult: scanResult)
        let stateSpy = ValueSpy(sut.$state)
        
        sut.qrModel.action.send(result)
        spy.complete(with: qrResult)
        
        XCTAssertNoDiff(stateSpy.values, [nil, .inflight, .qrResult(qrResult)])
    }
    
    func test_close_shouldChangeState() {
        
        let scanResult: QRViewModel.ScanResult = .c2bURL(anyURL())
        let (sut, _) = makeSUT(scanResult: scanResult)
        let stateSpy = ValueSpy(sut.$state)
        
        sut.qrModel.closeButton.action()
        
        XCTAssertNoDiff(stateSpy.values, [nil, .cancelled])
    }
    
    // MARK: - Helpers
    
    private typealias QRResult = String
    private typealias SUT = QRModelWrapper<QRResult>
    private typealias MapScanResultSpy = Spy<QRViewModel.ScanResult, QRResult, Never>
    
    private func makeSUT(
        qrResult: QRResult = anyMessage(),
        scanResult: QRViewModel.ScanResult = .unknown,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: SUT,
        spy: MapScanResultSpy
    ) {
        let spy = MapScanResultSpy()
        let sut = SUT(
            mapScanResult: spy.process,
            makeQRModel: {
                
                return .init(
                    closeAction: $0,
                    qrResolve: { _ in scanResult }
                )
            },
            scheduler: .immediate
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(spy, file: file, line: line)
        
        return (sut, spy)
    }
}
