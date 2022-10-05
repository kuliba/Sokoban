//
//  PaymentsOperationTests.swift
//  ForaBankTests
//
//  Created by Max Gribov on 08.02.2022.
//

import XCTest
@testable import ForaBank

class PaymentsOperationTests: XCTestCase {}

//MARK: - Parameters

extension PaymentsOperationTests {
    
    func testParameters() throws {
        
        // given
        let paramOne = Payments.ParameterMock(id: "one", value: "100")
        let paramTwo = Payments.ParameterMock(id: "two", value: "200")
        let operation = Payments.Operation(service: .fms, source: .none, steps: [.init(parameters: [paramOne], terms: nil, processed: nil), .init(parameters: [paramTwo], terms: nil, processed: nil)])
        
        // when
        let result = operation.parameters
        
        // then
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[0].id, paramOne.id)
        XCTAssertEqual(result[1].id, paramTwo.id)
    }
}

//MARK: - Next Step

extension PaymentsOperationTests {
   
    func testNextStep_Zero() throws {
        
        // given
        let operation = Payments.Operation(service: .fms, source: .none, steps: [])
        
        // when
        let result = operation.nextStep
        
        // then
        XCTAssertEqual(result, 0)
    }
    
    func testNextStep_One() throws {
        
        // given
        let operation = Payments.Operation(service: .fms, source: .none, steps: [.init(parameters: [], terms: nil, processed: nil)])
        
        // when
        let result = operation.nextStep
        
        // then
        XCTAssertEqual(result, 1)
    }
}

//MARK: - Appending Parameters

extension PaymentsOperationTests {
    
    func testAppendingParameters_Step_Zero_Terms_Same_Step() throws {
        
        // given
        let paramOne = Payments.ParameterMock(id: "one", value: "100")
        let paramTwo = Payments.ParameterMock(id: "two", value: "200")
        let operation = Payments.Operation(service: .fms, source: .none, steps: [])
        let terms: [Payments.Operation.Step.Term] = [.init(parameterId: paramOne.id, impact: .rollback)]
        
        // when
        let result = try operation.appending(parameters: [paramOne, paramTwo], terms: terms)
        
        // then
        XCTAssertEqual(result.parameters.count, 2)
        XCTAssertEqual(result.steps.count, 1)
        XCTAssertEqual(result.steps[0].parameters.count, 2)
        XCTAssertEqual(result.steps[0].parameters[0].id, paramOne.id)
        XCTAssertEqual(result.steps[0].parameters[1].id, paramTwo.id)
        XCTAssertNotNil(result.steps[0].terms)
        XCTAssertEqual(result.steps[0].terms![0].parameterId, paramOne.id)
        XCTAssertNil(result.steps[0].processed)
    }
    
    func testAppendingParameters_Step_One_Terms_Same_Step() throws {
        
        // given
        let paramOne = Payments.ParameterMock(id: "one", value: "100")
        let paramTwo = Payments.ParameterMock(id: "two", value: "200")
        let stepOne = Payments.Operation.Step(parameters: [paramOne], terms: nil, processed: nil)
        let operation = Payments.Operation(service: .fms, source: .none, steps: [stepOne])
        let terms: [Payments.Operation.Step.Term] = [.init(parameterId: paramTwo.id, impact: .rollback)]
        
        // when
        let result = try operation.appending(parameters: [paramTwo], terms: terms)
        
        // then
        XCTAssertEqual(result.parameters.count, 2)
        XCTAssertEqual(result.steps.count, 2)
        // step 1
        XCTAssertEqual(result.steps[0].parameters.count, 1)
        XCTAssertEqual(result.steps[0].parameters[0].id, paramOne.id)
        XCTAssertNil(result.steps[0].terms)
        XCTAssertNil(result.steps[0].processed)
        // step 2
        XCTAssertEqual(result.steps[1].parameters.count, 1)
        XCTAssertEqual(result.steps[1].parameters[0].id, paramTwo.id)
        XCTAssertNotNil(result.steps[1].terms)
        XCTAssertEqual(result.steps[1].terms!.count, 1)
        XCTAssertEqual(result.steps[1].terms![0].parameterId, paramTwo.id)
        XCTAssertNil(result.steps[1].processed)
    }
    
    func testAppendingParameters_Terms_Different_Steps() throws {
        
        // given
        let paramOne = Payments.ParameterMock(id: "one", value: "100")
        let paramTwo = Payments.ParameterMock(id: "two", value: "200")
        let stepOne = Payments.Operation.Step(parameters: [paramOne], terms: nil, processed: nil)
        let operation = Payments.Operation(service: .fms, source: .none, steps: [stepOne])
        let terms: [Payments.Operation.Step.Term] = [.init(parameterId: paramTwo.id, impact: .rollback), .init(parameterId: paramOne.id, impact: .restart)]
        
        // when
        let result = try operation.appending(parameters: [paramTwo], terms: terms)
        
        // then
        XCTAssertEqual(result.parameters.count, 2)
        XCTAssertEqual(result.steps.count, 2)
        // step 1
        XCTAssertEqual(result.steps[0].parameters.count, 1)
        XCTAssertEqual(result.steps[0].parameters[0].id, paramOne.id)
        XCTAssertNil(result.steps[0].terms)
        XCTAssertNil(result.steps[0].processed)
        // step 2
        XCTAssertEqual(result.steps[1].parameters.count, 1)
        XCTAssertEqual(result.steps[1].parameters[0].id, paramTwo.id)
        XCTAssertNotNil(result.steps[1].terms)
        XCTAssertEqual(result.steps[1].terms!.count, 2)
        XCTAssertEqual(result.steps[1].terms![0].parameterId, paramTwo.id)
        XCTAssertEqual(result.steps[1].terms![1].parameterId, paramOne.id)
        XCTAssertNil(result.steps[1].processed)
    }
    
    func testAppendingParameters_Terms_Incorrect() throws {
        
        // given
        let paramOne = Payments.ParameterMock(id: "one", value: "100")
        let paramTwo = Payments.ParameterMock(id: "two", value: "200")
        let stepOne = Payments.Operation.Step(parameters: [paramOne], terms: nil, processed: nil)
        let operation = Payments.Operation(service: .fms, source: .none, steps: [stepOne])
        let terms: [Payments.Operation.Step.Term] = [.init(parameterId: paramTwo.id, impact: .rollback), .init(parameterId: paramOne.id, impact: .restart), .init(parameterId: "unexpected", impact: .restart)]
        
        // then
        XCTAssertThrowsError(try operation.appending(parameters: [paramTwo], terms: terms))
    }
    
    func testAppendingParameters_Wrong_Number() throws {
        
        // given
        let operation = Payments.Operation(service: .fms, source: .none, steps: [])
        
        // then
        XCTAssertThrowsError(try operation.appending(parameters: []))
    }
}


//MARK: - Updated

extension PaymentsOperationTests {
    
    func testUpdated_Correct() throws {
        
        // given
        let paramOne = Payments.ParameterMock(id: "one", value: "100")
        let paramTwo = Payments.ParameterMock(id: "two", value: "200")
        let stepOne = Payments.Operation.Step(parameters: [paramOne, paramTwo], terms: nil, processed: nil)
        let operation = Payments.Operation(service: .fms, source: .none, steps: [stepOne])
        let update = Payments.Parameter(id: "two", value: "300")
        
        // when
        let result = operation.updated(with: [update])
        
        // then
        XCTAssertEqual(result.parameters.count, 2)
        XCTAssertEqual(result.parameters[0].value, paramOne.value)
        XCTAssertEqual(result.parameters[1].value, update.value)
    }
    
    func testUpdated_Duplicate_Params() throws {
        
        // given
        let paramOne = Payments.ParameterMock(id: "one", value: "100")
        let paramTwo = Payments.ParameterMock(id: "two", value: "200")
        let paramTwoDuplicate = Payments.ParameterMock(id: "two", value: "200")
        let stepOne = Payments.Operation.Step(parameters: [paramOne, paramTwo], terms: nil, processed: nil)
        let stepTwo = Payments.Operation.Step(parameters: [paramTwoDuplicate], terms: nil, processed: nil)
        let operation = Payments.Operation(service: .fms, source: .none, steps: [stepOne, stepTwo])
        let update = Payments.Parameter(id: "two", value: "300")
        
        // when
        let result = operation.updated(with: [update])
        
        // then
        XCTAssertEqual(result.parameters.count, 3)
        XCTAssertEqual(result.parameters[0].value, paramOne.value)
        XCTAssertEqual(result.parameters[1].value, update.value)
        XCTAssertEqual(result.parameters[2].value, update.value)
    }
    
    func testUpdated_Unexpected_No_Change() throws {
        
        // given
        let paramOne = Payments.ParameterMock(id: "one", value: "100")
        let paramTwo = Payments.ParameterMock(id: "two", value: "200")
        let stepOne = Payments.Operation.Step(parameters: [paramOne, paramTwo], terms: nil, processed: nil)
        let operation = Payments.Operation(service: .fms, source: .none, steps: [stepOne])
        let update = Payments.Parameter(id: "unexpected", value: "300")
        
        // when
        let result = operation.updated(with: [update])
        
        // then
        XCTAssertEqual(result.parameters.count, 2)
        XCTAssertEqual(result.parameters[0].value, paramOne.value)
        XCTAssertEqual(result.parameters[1].value, paramTwo.value)
    }
}

//MARK: - Rollback

extension PaymentsOperationTests {
    
    func testRollback_Correct() throws {
        
        // given
        let paramOne = Payments.ParameterMock(id: "one", value: "100")
        let stepOne = Payments.Operation.Step(parameters: [paramOne], terms: [.init(parameterId: paramOne.id, impact: .rollback)], processed: [paramOne.parameter])
        
        let paramTwo = Payments.ParameterMock(id: "two", value: "200")
        let stepTwo = Payments.Operation.Step(parameters: [paramTwo], terms: [.init(parameterId: paramTwo.id, impact: .restart)], processed: [paramTwo.parameter])
        
        let paramThree = Payments.ParameterMock(id: "three", value: "300")
        let stepThree = Payments.Operation.Step(parameters: [paramThree], terms: [.init(parameterId: paramThree.id, impact: .rollback)], processed: [paramThree.parameter])
        
        let operation = Payments.Operation(service: .fms, source: .none, steps: [stepOne, stepTwo, stepThree])
        
        // when
        let result = try operation.rollback(to: 1)
        
        // then
        XCTAssertEqual(result.steps.count, 2)
        
        // step one
        XCTAssertEqual(result.steps[0].parameters.count, 1)
        XCTAssertEqual(result.steps[0].parameters[0].id, paramOne.id)
        XCTAssertEqual(result.steps[0].parameters[0].value, paramOne.value)
        XCTAssertNotNil(result.steps[0].terms)
        XCTAssertEqual(result.steps[0].terms!.count, 1)
        XCTAssertEqual(result.steps[0].terms![0].parameterId, paramOne.id)
        XCTAssertEqual(result.steps[0].terms![0].impact, .rollback)
        XCTAssertNil(result.steps[0].processed)
        
        // step two
        XCTAssertEqual(result.steps[1].parameters.count, 1)
        XCTAssertEqual(result.steps[1].parameters[0].id, paramTwo.id)
        XCTAssertEqual(result.steps[1].parameters[0].value, paramTwo.value)
        XCTAssertNotNil(result.steps[1].terms)
        XCTAssertEqual(result.steps[1].terms!.count, 1)
        XCTAssertEqual(result.steps[1].terms![0].parameterId, paramTwo.id)
        XCTAssertEqual(result.steps[1].terms![0].impact, .restart)
        XCTAssertNil(result.steps[1].processed)
    }
    
    func testRollback_Step_Index_Incorrect() throws {
        
        // given
        let paramOne = Payments.ParameterMock(id: "one", value: "100")
        let stepOne = Payments.Operation.Step(parameters: [paramOne], terms: [.init(parameterId: paramOne.id, impact: .rollback)], processed: [paramOne.parameter])
        
        let paramTwo = Payments.ParameterMock(id: "two", value: "200")
        let stepTwo = Payments.Operation.Step(parameters: [paramTwo], terms: [.init(parameterId: paramTwo.id, impact: .restart)], processed: [paramTwo.parameter])
        
        let paramThree = Payments.ParameterMock(id: "three", value: "300")
        let stepThree = Payments.Operation.Step(parameters: [paramThree], terms: [.init(parameterId: paramThree.id, impact: .rollback)], processed: [paramThree.parameter])
        
        let operation = Payments.Operation(service: .fms, source: .none, steps: [stepOne, stepTwo, stepThree])
        
        // then
        XCTAssertThrowsError(try operation.rollback(to: 5))
    }
}

//MARK: - Processed

extension PaymentsOperationTests {
    
    func testProcessed_Correct() throws {
        
        // given
        let paramOne = Payments.ParameterMock(id: "one", value: "100")
        let stepOne = Payments.Operation.Step(parameters: [paramOne], terms: [.init(parameterId: paramOne.id, impact: .rollback)], processed: [paramOne.parameter])
        
        let paramTwo = Payments.ParameterMock(id: "two", value: "200")
        let stepTwo = Payments.Operation.Step(parameters: [paramTwo], terms: [.init(parameterId: paramTwo.id, impact: .restart)], processed: nil)
        
        let paramThree = Payments.ParameterMock(id: "three", value: "300")
        let stepThree = Payments.Operation.Step(parameters: [paramThree], terms: [.init(parameterId: paramThree.id, impact: .rollback)], processed: nil)
        
        let operation = Payments.Operation(service: .fms, source: .none, steps: [stepOne, stepTwo, stepThree])
        
        // when
        let result = try operation.processed(parameters: [paramTwo.parameter], stepIndex: 1)
        
        // then
        XCTAssertNotNil(result.steps[1].processed)
        XCTAssertEqual(result.steps[1].processed!.count, 1)
        XCTAssertEqual(result.steps[1].processed![0].id, paramTwo.id)
        XCTAssertEqual(result.steps[1].processed![0].value, paramTwo.value)
    }
    
    
}
