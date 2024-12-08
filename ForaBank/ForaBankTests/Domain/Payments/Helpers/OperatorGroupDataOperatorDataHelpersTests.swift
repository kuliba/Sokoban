//
//  OperatorGroupDataOperatorDataHelpersTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 22.02.2023.
//

@testable import Vortex
import XCTest

final class OperatorGroupDataOperatorDataHelpersTests: XCTestCase {
    
    // MARK: - operatorID
    
    func test_operatorID_iVortex4285() {
        
        let data = OperatorGroupData.OperatorData.iVortex4285
        
        XCTAssertEqual(data.operatorID, "a3_NUMBER_1_2")
    }
    
    func test_operatorID_iVortex4286() {
        
        let data = OperatorGroupData.OperatorData.iVortex4286
        
        XCTAssertEqual(data.operatorID, "a3_NUMBER_1_2")
    }
    
    func test_operatorID_iVortex515A3() {
        
        let data = OperatorGroupData.OperatorData.iVortex515A3
        
        XCTAssertEqual(data.operatorID, nil)
    }
    
    // MARK: - parameter(for:)
    
    func test_parameterFor_iVortex4285() {
        
        let data = OperatorGroupData.OperatorData.iVortex4285
        
        XCTAssertEqual(data.parameter(for: \.title), "Номер телефона +7")
        XCTAssertEqual(data.parameter(for: \.subTitle), "Пример: 9021111111")
    }
    
    func test_parameterFor_iVortex4286() {
        
        let data = OperatorGroupData.OperatorData.iVortex4286
        
        XCTAssertEqual(data.parameter(for: \.title), "Номер телефона +7")
        XCTAssertEqual(data.parameter(for: \.subTitle), "Пример: 9021111111")
    }
    
    func test_parameterFor_iVortex515A3() {
        
        let data = OperatorGroupData.OperatorData.iVortex515A3
        
        XCTAssertEqual(data.parameter(for: \.title), nil)
        XCTAssertEqual(data.parameter(for: \.subTitle), nil)
    }
}
