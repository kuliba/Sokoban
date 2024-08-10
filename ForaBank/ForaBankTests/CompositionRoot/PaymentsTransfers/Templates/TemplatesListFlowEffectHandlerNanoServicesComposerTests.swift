//
//  TemplatesListFlowEffectHandlerNanoServicesComposerTests.swift
//  ForaBankTests
//
//  Created by Igor Malyarov on 10.08.2024.
//

@testable import ForaBank
import XCTest

final class TemplatesListFlowEffectHandlerNanoServicesComposerTests: XCTestCase {
    
    func test() {
        
        let sut = makeSUT()
    }

    // MARK: - Helpers
    
    private typealias SUT = TemplatesListFlowEffectHandlerNanoServicesComposer
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> SUT {
        
        let sut = SUT()
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }

}
