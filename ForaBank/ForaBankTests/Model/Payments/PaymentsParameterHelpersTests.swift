//
//  PaymentsParameterHelpersTests.swift
//  VortexTests
//
//  Created by Max Gribov on 07.09.2022.
//

import XCTest
@testable import ForaBank

class PaymentsParameterHelpersTests: XCTestCase {

    let model: Model = .mockWithEmptyExcept()
}

extension PaymentsParameterHelpersTests {
    
    // MARK: Payments Header Helper Tests
    
    func test_parameterHeader_helper_withOutTemplate_shouldSetup_incomingHeader() throws {

        // given
        let header = Payments.ParameterHeader(title: "title")
        
        // when
        let sut = model.parameterHeader(
            source: .template(1),
            header: header
        )
        
        // then
        XCTAssertEqual(sut.title, header.title)
        XCTAssertEqual(sut.id, header.id)
    }
    
    func test_parameterHeader_helper_withOutSource_shouldReturn_header() throws {

        // given
        let header = Payments.ParameterHeader(title: "title")
        
        // when
        let sut = model.parameterHeader(
            source: nil,
            header: header
        )
        
        // then
        XCTAssertEqual(sut.title, header.title)
        XCTAssertEqual(sut.id, header.id)
    }
    
    func test_parameterHeader_helper_sourceTemplate_shouldReturn_templateHeader() throws {

        // given
        let header = Payments.ParameterHeader(title: "title")
        model.paymentTemplates.value.append(.templateStub(
            paymentTemplateId: 1,
            type: .betweenTheir,
            parameterList: [])
        )
        
        // when
        let sut = model.parameterHeader(
            source: .template(1),
            header: header
        )
        
        // then
        XCTAssertEqual(sut.title, "name")
    }
}
