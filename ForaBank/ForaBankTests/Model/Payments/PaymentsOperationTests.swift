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
        let history: [[Parameter.Result]] = [
            [.init(id: "01", value: "100")],
            [.init(id: "01", value: "100"), .init(id: "02", value: "200")],
            [.init(id: "01", value: "100"), .init(id: "02", value: "200"), .init(id: "03", value: "300")]]
        let changedValue = Parameter.Result(id: "01", value: "200")
        
        // when
        let result = Operation.historyStepChanged(history: history, value: changedValue)
        
        // then
        XCTAssertNotNil(result)
        XCTAssertEqual(result, 0)
    }
    
    func testHistoryStepChanged_Value_Step_1() throws {
        
        // given
        let history: [[Parameter.Result]] = [
            [.init(id: "01", value: "100")],
            [.init(id: "01", value: "100"), .init(id: "02", value: "200")],
            [.init(id: "01", value: "100"), .init(id: "02", value: "200"), .init(id: "03", value: "300")]]
        let changedValue = Parameter.Result(id: "02", value: "300")
        
        // when
        let result = Operation.historyStepChanged(history: history, value: changedValue)
        
        // then
        XCTAssertNotNil(result)
        XCTAssertEqual(result, 1)
    }
    
    func testHistoryStepChanged_Value_Step_Not_Changed() throws {
        
        // given
        let history: [[Parameter.Result]] = [
            [.init(id: "01", value: "100")],
            [.init(id: "01", value: "100"), .init(id: "02", value: "200")],
            [.init(id: "01", value: "100"), .init(id: "02", value: "200"), .init(id: "03", value: "300")]]
        let changedValue = Parameter.Result(id: "05", value: "300")
        
        // when
        let result = Operation.historyStepChanged(history: history, value: changedValue)
        
        // then
        XCTAssertNil(result)
    }
    
    //MARK: - Values
    
    func testHistoryStepChanged_Values_Step_0() throws {
        
        // given
        let history: [[Parameter.Result]] = [
            [.init(id: "01", value: "100")],
            [.init(id: "01", value: "100"), .init(id: "02", value: "200")],
            [.init(id: "01", value: "100"), .init(id: "02", value: "200"), .init(id: "03", value: "300")]]
        let changedValues: [Parameter.Result] = [.init(id: "01", value: "200"),
                                                .init(id: "02", value: "300")]
        
        // when
        let result = Operation.historyStepChanged(history: history, values: changedValues)
        
        // then
        XCTAssertNotNil(result)
        XCTAssertEqual(result, 0)
    }
    
    func testHistoryStepChanged_Values_Step_1() throws {
        
        // given
        let history: [[Parameter.Result]] = [
            [.init(id: "01", value: "100")],
            [.init(id: "01", value: "100"), .init(id: "02", value: "200")],
            [.init(id: "01", value: "100"), .init(id: "02", value: "200"), .init(id: "03", value: "300")]]
        let changedValues: [Parameter.Result] = [.init(id: "01", value: "100"),
                                                .init(id: "02", value: "300")]
        
        // when
        let result = Operation.historyStepChanged(history: history, values: changedValues)
        
        // then
        XCTAssertNotNil(result)
        XCTAssertEqual(result, 1)
    }
    
    func testHistoryStepChanged_Values_Step_Not_Changed() throws {
        
        // given
        let history: [[Parameter.Result]] = [
            [.init(id: "01", value: "100")],
            [.init(id: "01", value: "100"), .init(id: "02", value: "200")],
            [.init(id: "01", value: "100"), .init(id: "02", value: "200"), .init(id: "03", value: "300")]]
        let changedValues: [Parameter.Result] = [.init(id: "04", value: "100"),
                                                .init(id: "05", value: "300")]
        
        // when
        let result = Operation.historyStepChanged(history: history, values: changedValues)
        
        // then
        XCTAssertNil(result)
    }
}
