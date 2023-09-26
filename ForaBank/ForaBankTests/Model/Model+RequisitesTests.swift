//
//  Model+RequisitesTests.swift
//  ForaBankTests
//
//  Created by Дмитрий Савушкин on 19.09.2023.
//

import XCTest
@testable import ForaBank

final class Model_RequisitesTests: XCTestCase {
    
    // MARK: GetCompanyNameParameter Tests
    
    func test_getCompanyNameParameter_withRequisitesService_shouldReturnSuggestCompaniesNameValue() throws {
        
        let sut = makeSUT()
        
        let companyParameter = try sut.getCompanyNameParameter(
            .init(service: .requisites),
            .directCard,
            .anyValue,
            [(kpp: "kpp", name: "suggestCompanyName")]
        )
        
        _ = XCTWaiter().wait(for: [.init()], timeout: 0.1)
        
        XCTAssertNoDiff(companyParameter.parameter.value, "suggestCompanyName")
    }
    
    func test_getCompanyNameParameter_withTemplateOperation_shouldReturnTemplateNameValue() throws {
        
        let sut = makeSUT()
        
        let companyParameter = try sut.getCompanyNameParameter(
            .init(service: .abroad, source: .template(1)),
            .directCard,
            .anyValue,
            []
        )
        
        XCTAssertNoDiff(companyParameter.parameter.value, "name")
    }
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line) -> Model {
            
            let sut = Model.mockWithEmptyExcept()
            
            sut.paymentTemplates.value.append(.templateStub(
                paymentTemplateId: 1,
                type: .betweenTheir)
            )
            
            trackForMemoryLeaks(sut, file: file, line: line)
            
            return sut
        }
}
