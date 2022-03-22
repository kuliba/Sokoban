//
//  PaymentsOperationTests.swift
//  ForaBankTests
//
//  Created by Max Gribov on 08.02.2022.
//

import XCTest
@testable import ForaBank

class PaymentsOperationTests: XCTestCase {
    
    typealias Parameter = Payments.Parameter
    typealias Operation = Payments.Operation

    //MARK: - Value
    
    func testHistoryStepChanged_Value_Step_0() throws {
        
        // given
        let operation = Operation(service: .fms, parameters: [], history: [[]])
        let history: [[Parameter]] = [
            [.init(id: "01", value: "100")],
            [.init(id: "01", value: "100"), .init(id: "02", value: "200")],
            [.init(id: "01", value: "100"), .init(id: "02", value: "200"), .init(id: "03", value: "300")]]
        let parameterResult = Parameter(id: "01", value: "200")
        
        // when
        let result = operation.historyChangedStep(history: history, result: (parameterResult, true))
        
        // then
        XCTAssertNotNil(result)
        XCTAssertEqual(result, 0)
    }
    
    func testHistoryStepChanged_Value_Step_1() throws {
        
        // given
        let operation = Operation(service: .fms, parameters: [], history: [[]])
        let history: [[Parameter]] = [
            [.init(id: "01", value: "100")],
            [.init(id: "01", value: "100"), .init(id: "02", value: "200")],
            [.init(id: "01", value: "100"), .init(id: "02", value: "200"), .init(id: "03", value: "300")]]
        let parameterResult = Parameter(id: "02", value: "300")
        
        // when
        let result = operation.historyChangedStep(history: history, result: (parameterResult, true))
        
        // then
        XCTAssertNotNil(result)
        XCTAssertEqual(result, 1)
    }
    
    func testHistoryStepChanged_Value_Step_Not_Changed() throws {
        
        // given
        let operation = Operation(service: .fms, parameters: [], history: [[]])
        let history: [[Parameter]] = [
            [.init(id: "01", value: "100")],
            [.init(id: "01", value: "100"), .init(id: "02", value: "200")],
            [.init(id: "01", value: "100"), .init(id: "02", value: "200"), .init(id: "03", value: "300")]]
        let parameterResult = Parameter(id: "05", value: "300")
        
        // when
        let result = operation.historyChangedStep(history: history, result: (parameterResult, true))
        
        // then
        XCTAssertNil(result)
    }
    
    //MARK: - Values
    
    func testHistoryStepChanged_Values_Step_0() throws {
        
        // given
        let operation = Operation(service: .fms, parameters: [], history: [[]])
        let history: [[Parameter]] = [
            [.init(id: "01", value: "100")],
            [.init(id: "01", value: "100"), .init(id: "02", value: "200")],
            [.init(id: "01", value: "100"), .init(id: "02", value: "200"), .init(id: "03", value: "300")]]
        let results: [Parameter] = [.init(id: "01", value: "200"),
                                                .init(id: "02", value: "300")]
        
        // when
        let result = operation.historyChangedStep(history: history, results: results.map{($0, true)})
        
        // then
        XCTAssertNotNil(result)
        XCTAssertEqual(result, 0)
    }
    
    func testHistoryStepChanged_Values_Step_1() throws {
        
        // given
        let operation = Operation(service: .fms, parameters: [], history: [[]])
        let history: [[Parameter]] = [
            [.init(id: "01", value: "100")],
            [.init(id: "01", value: "100"), .init(id: "02", value: "200")],
            [.init(id: "01", value: "100"), .init(id: "02", value: "200"), .init(id: "03", value: "300")]]
        let results: [Parameter] = [.init(id: "01", value: "100"),
                                                .init(id: "02", value: "300")]
        
        // when
        let result = operation.historyChangedStep(history: history, results: results.map{($0, true)})
        
        // then
        XCTAssertNotNil(result)
        XCTAssertEqual(result, 1)
    }
    
    func testHistoryStepChanged_Values_Step_Not_Changed() throws {
        
        // given
        let operation = Operation(service: .fms, parameters: [], history: [[]])
        let history: [[Parameter]] = [
            [.init(id: "01", value: "100")],
            [.init(id: "01", value: "100"), .init(id: "02", value: "200")],
            [.init(id: "01", value: "100"), .init(id: "02", value: "200"), .init(id: "03", value: "300")]]
        let results: [Parameter] = [.init(id: "04", value: "100"),
                                                .init(id: "05", value: "300")]
        
        // when
        let result = operation.historyChangedStep(history: history, results: results.map{($0, true)})
        
        // then
        XCTAssertNil(result)
    }
}
