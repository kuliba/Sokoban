//
//  TemplatesListViewModel+GetPhoneNumberTests.swift
//  ForaBankTests
//
//  Created by Andryusina Nataly on 15.11.2023.
//

@testable import ForaBank
import XCTest

final class TemplatesListViewModel_GetPhoneNumberTests: XCTestCase {
    
    // MARK: - test mobile
    
    func test_getPhoneNumber_mobileWithOutPhone_shouldReturnNil() {
        
        let sut = makeSUT()
        
        let result = sut.getPhoneNumber(for: .mobileWithOutPhone)
        
        XCTAssertNil(result)
    }
    
    func test_getPhoneNumber_mobile10Digits_shouldReturnPhoneFormatted() {
        
        let sut = makeSUT()
        
        let result = sut.getPhoneNumber(for: .mobile10Digits)
        
        XCTAssertNoDiff(result, "+7 963 000-00-00")
    }
    
    func test_getPhoneNumber_mobileLess10Digits_shouldReturnPhoneFormatted() {
        
        let sut = makeSUT()
        
        let result = sut.getPhoneNumber(for: .mobileLess10Digits)
        
        XCTAssertNoDiff(result, "+963 000 000")
    }
    
    func test_getPhoneNumber_mobileMore10Digits_shouldReturnPhoneFormatted() {
        
        let sut = makeSUT()
        
        let result = sut.getPhoneNumber(for: .mobileMore10Digits)
        
        XCTAssertNoDiff(result, "+963 000 000 00")
    }
    
    // MARK: - test sfp

    func test_getPhoneNumber_sfpWithOutPhone_shouldReturnNil() {
        
        let sut = makeSUT()
        
        let result = sut.getPhoneNumber(for: .sfpWithOutPhone)
        
        XCTAssertNil(result)
    }
    
    func test_getPhoneNumber_sfpPhone10Digits_shouldReturnPhoneFormatted() {
        
        let sut = makeSUT()
        
        let result = sut.getPhoneNumber(for: .sfpPhone10Digits)
        
        XCTAssertNoDiff(result, "+7 963 000-00-00")
    }
    
    func test_getPhoneNumber_sfpPhoneLess10Digits_shouldReturnPhoneFormatted() {
        
        let sut = makeSUT()
        
        let result = sut.getPhoneNumber(for: .sfpPhoneLess10Digits)
        
        XCTAssertNoDiff(result, "+963 000 000")
    }
    
    func test_getPhoneNumber_sfpPhoneMore10Digits_shouldReturnPhoneFormatted() {
        
        let sut = makeSUT()
        
        let result = sut.getPhoneNumber(for: .sfpPhoneMore10Digits)
        
        XCTAssertNoDiff(result, "+963 000 000 00")
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> TemplatesListViewModel {
        
        let model: Model = .mockWithEmptyExcept()
        
        let sut: TemplatesListViewModel = .init(
            state: .normal,
            style: .list,
            navBarState: .search(.init()),
            categorySelector: nil,
            items: [],
            deletePannel: nil,
            updateFastAll: {},
            model: model
        )
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
}
