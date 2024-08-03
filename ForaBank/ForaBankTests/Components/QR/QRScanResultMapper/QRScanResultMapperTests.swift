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
    
    // MARK: - Helpers
    
    private typealias SUT = QRScanResultMapper
    private typealias LoadResult = SUT.MicroServices.LoadResult
    private typealias GetOperatorsSpy = Spy<(QRCode, QRMapping), LoadResult, Never>
    
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
    
}
