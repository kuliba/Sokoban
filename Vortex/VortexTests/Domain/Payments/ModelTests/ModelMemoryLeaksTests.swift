//
//  ModelMemoryLeaksTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 21.02.2023.
//

@testable import Vortex
import XCTest

#if MOCK
final class ModelMemoryLeaksTests: XCTestCase {
    
    func test_modelMemoryLeaks() async throws {
        
        let sut = makeSUT([:], [])
        
        XCTAssertNotNil(sut)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        _ counts: [ProductType : Int],
        _ currencies: [CurrencyData],
        file: StaticString = #file,
        line: UInt = #line
    ) -> Model {
        
        let serverAgent = ServerAgentStub(stub: [:], essenceStub: [:])
        let sut: Model = .stubbed(
            serverAgent: serverAgent
        )
        sut.products.sessionIDValue = makeProductsData(counts)
        sut.currencyList.sessionIDValue = currencies
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(serverAgent, file: file, line: line)
        
        return sut
    }
}
#endif
