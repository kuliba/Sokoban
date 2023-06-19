//
//  PaymentsSectionViewModelTests.swift
//  ForaBankTests
//
//  Created by Max Gribov on 28.10.2022.
//

import XCTest
@testable import ForaBank

class PaymentsSectionViewModelTests: XCTestCase {}


extension PaymentsSectionViewModelTests {
    
    func testReduceOperation_Feed_All_Visible() throws {
        
        // given
        let paramOne = Payments.ParameterMock(id: "one", value: nil, placement: .feed)
        let paramTwo = Payments.ParameterMock(id: "two", value: nil, placement: .feed)
        let paramThree = Payments.ParameterMock(id: "three", value: nil, placement: .feed)

        let parameters = [paramOne, paramTwo, paramThree]
        let visible = parameters.map{ $0.id }
        let step = Payments.Operation.Step(parameters: parameters, front: .init(visible: visible, isCompleted: false), back: .init(stage: .local, required: [], processed: nil))
        let operation = Payments.Operation(service: .fms, source: nil, steps: [], visible: [])
        let operationUpdated = try operation.appending(step: step)
        
        // when
        let result = PaymentsSectionViewModel.reduce(operation: operationUpdated, model: .emptyMock)
        
        // then
        XCTAssertEqual(result[0].groups.count, 3)
        XCTAssertEqual(result[0].placement, .feed)
        XCTAssertEqual(result[0].items[0].source.parameter, paramOne.parameter)
        XCTAssertEqual(result[0].items[1].source.parameter, paramTwo.parameter)
        XCTAssertEqual(result[0].items[2].source.parameter, paramThree.parameter)
    }
    
    func testReduceOperation_Feed_Visible_Partly() throws {
        
        // given
        let paramOne = Payments.ParameterMock(id: "one", value: nil, placement: .feed)
        let paramTwo = Payments.ParameterMock(id: "two", value: nil, placement: .feed)
        let paramThree = Payments.ParameterMock(id: "three", value: nil, placement: .feed)

        let parameters = [paramOne, paramTwo, paramThree]
        let visible = [paramOne.id, paramThree.id]
        let step = Payments.Operation.Step(parameters: parameters, front: .init(visible: visible, isCompleted: false), back: .init(stage: .local, required: [], processed: nil))
        let operation = Payments.Operation(service: .fms, source: nil, steps: [], visible: [])
        let operationUpdated = try operation.appending(step: step)
        
        // when
        let result = PaymentsSectionViewModel.reduce(operation: operationUpdated, model: .emptyMock)
        
        // then
        XCTAssertEqual(result[0].groups.count, 2)
        XCTAssertEqual(result[0].placement, .feed)
        XCTAssertEqual(result[0].items[0].source.parameter, paramOne.parameter)
        XCTAssertEqual(result[0].items[1].source.parameter, paramThree.parameter)
    }
    
    func testReduceOperation_Feed_And_Spoiler() throws {
        
        // given
        let paramOne = Payments.ParameterMock(id: "one", value: nil, placement: .feed)
        let paramTwo = Payments.ParameterMock(id: "two", value: nil, placement: .feed)
        
        let spoilerGroup = Payments.Parameter.Group(id: UUID().uuidString, type: .spoiler)
        let paramThree = Payments.ParameterMock(id: "three", value: nil, placement: .feed, group: spoilerGroup)
        let paramFour = Payments.ParameterMock(id: "four", value: nil, placement: .feed, group: spoilerGroup)
        
        let paramFive = Payments.ParameterMock(id: "five", value: nil, placement: .feed)
        
        let parameters = [paramOne, paramTwo, paramThree, paramFour, paramFive]
        let visible = parameters.map{ $0.id }
        let step = Payments.Operation.Step(parameters: parameters, front: .init(visible: visible, isCompleted: false), back: .init(stage: .local, required: [], processed: nil))
        let operation = Payments.Operation(service: .fms, source: nil, steps: [], visible: [])
        let operationUpdated = try operation.appending(step: step)
        
        // when
        let result = PaymentsSectionViewModel.reduce(operation: operationUpdated, model: .emptyMock)
        
        // then
        XCTAssertEqual(result[0].groups.count, 4)
        XCTAssertEqual(result[0].placement, .feed)
        XCTAssertIdentical(type(of: result[0].groups[0]), PaymentsGroupViewModel.self)
        XCTAssertIdentical(type(of: result[0].groups[1]), PaymentsGroupViewModel.self)
        XCTAssertIdentical(type(of: result[0].groups[2]), PaymentsSpoilerGroupViewModel.self)
        XCTAssertIdentical(type(of: result[0].groups[3]), PaymentsGroupViewModel.self)
        XCTAssertEqual(result[0].groups[0].items[0].source.parameter, paramOne.parameter)
        XCTAssertEqual(result[0].groups[1].items[0].source.parameter, paramTwo.parameter)
        XCTAssertEqual(result[0].groups[2].items[0].source.parameter, paramThree.parameter)
        XCTAssertEqual(result[0].groups[2].items[1].source.parameter, paramFour.parameter)
        XCTAssertEqual(result[0].groups[3].items[0].source.parameter, paramFive.parameter)
    }
    
    func testReduceOperation_Feed_And_Spoiler_Mixed() throws {
        
        // given
        let spoilerGroup = Payments.Parameter.Group(id: UUID().uuidString, type: .spoiler)
        let paramOne = Payments.ParameterMock(id: "one", value: nil, placement: .feed)
        let paramTwo = Payments.ParameterMock(id: "two", value: nil, placement: .feed, group: spoilerGroup)
        let paramThree = Payments.ParameterMock(id: "three", value: nil, placement: .feed)
        let paramFour = Payments.ParameterMock(id: "four", value: nil, placement: .feed, group: spoilerGroup)
        let paramFive = Payments.ParameterMock(id: "five", value: nil, placement: .feed)
        
        let parameters = [paramOne, paramTwo, paramThree, paramFour, paramFive]
        let visible = parameters.map{ $0.id }
        let step = Payments.Operation.Step(parameters: parameters, front: .init(visible: visible, isCompleted: false), back: .init(stage: .local, required: [], processed: nil))
        let operation = Payments.Operation(service: .fms, source: nil, steps: [], visible: [])
        let operationUpdated = try operation.appending(step: step)
        
        // when
        let result = PaymentsSectionViewModel.reduce(operation: operationUpdated, model: .emptyMock)
        
        // then
        XCTAssertEqual(result[0].groups.count, 4)
        XCTAssertEqual(result[0].placement, .feed)
        XCTAssertIdentical(type(of: result[0].groups[0]), PaymentsGroupViewModel.self)
        XCTAssertIdentical(type(of: result[0].groups[1]), PaymentsSpoilerGroupViewModel.self)
        XCTAssertIdentical(type(of: result[0].groups[2]), PaymentsGroupViewModel.self)
        XCTAssertIdentical(type(of: result[0].groups[3]), PaymentsGroupViewModel.self)
        XCTAssertEqual(result[0].groups[0].items[0].source.parameter, paramOne.parameter)
        XCTAssertEqual(result[0].groups[1].items[0].source.parameter, paramTwo.parameter)
        XCTAssertEqual(result[0].groups[1].items[1].source.parameter, paramFour.parameter)
        XCTAssertEqual(result[0].groups[2].items[0].source.parameter, paramThree.parameter)
        XCTAssertEqual(result[0].groups[3].items[0].source.parameter, paramFive.parameter)
    }
}
