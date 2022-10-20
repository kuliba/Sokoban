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
        let stepOne = Payments.Operation.Step(parameters: [paramOne], front: .init(visible: [], isCompleted: false), back: nil)
        let stepTwo = Payments.Operation.Step(parameters: [paramTwo], front: .init(visible: [], isCompleted: false), back: nil)
        let operation = Payments.Operation(service: .fms, source: .none, steps: [stepOne, stepTwo])
        
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
        let stepOne = Payments.Operation.Step(parameters: [], front: .init(visible: [], isCompleted: false), back: nil)
        let operation = Payments.Operation(service: .fms, source: .none, steps: [stepOne])
        
        // when
        let result = operation.nextStep
        
        // then
        XCTAssertEqual(result, 1)
    }
}


//MARK: - Appending Parameters

extension PaymentsOperationTests {
    
    func testAppendingStep_First_Correct() throws {
        
        // given
        let operation = Payments.Operation(service: .fms, source: .none, steps: [])
        
        let paramOne = Payments.ParameterMock(id: "one", value: "100")
        let paramTwo = Payments.ParameterMock(id: "two", value: "200")
        let terms: [Payments.Operation.Step.Term] = [.init(parameterId: paramOne.id, impact: .rollback)]
        let paramProcessed = Payments.Parameter(id: "two", value: "300")
        let step = Payments.Operation.Step(parameters: [paramOne, paramTwo], front: .init(visible: [], isCompleted: false), back: .init(stage: .start, terms: terms, processed: [paramProcessed]))
        
        // when
        let result = try operation.appending(step: step)
        
        // then
        XCTAssertEqual(result.parameters.count, 2)
        XCTAssertEqual(result.steps.count, 1)
        XCTAssertEqual(result.steps[0].parameters.count, 2)
        XCTAssertEqual(result.steps[0].parameters[0].id, paramOne.id)
        XCTAssertEqual(result.steps[0].parameters[1].id, paramTwo.id)
        XCTAssertNotNil(result.steps[0].back?.terms)
        XCTAssertEqual(result.steps[0].back!.terms[0].parameterId, paramOne.id)
        XCTAssertNotNil(result.steps[0].back!.processed)
        XCTAssertEqual(result.steps[0].back!.processed!.count, 1)
        XCTAssertEqual(result.steps[0].back!.processed![0], paramProcessed)
    }
    
    func testAppendingStep_First_Empty_Back_Correct() throws {
        
        // given
        let operation = Payments.Operation(service: .fms, source: .none, steps: [])
        
        let paramOne = Payments.ParameterMock(id: "one", value: "100")
        let paramTwo = Payments.ParameterMock(id: "two", value: "200")
        let step = Payments.Operation.Step(parameters: [paramOne, paramTwo], front: .init(visible: [], isCompleted: false), back: nil)
        
        // when
        let result = try operation.appending(step: step)
        
        // then
        XCTAssertEqual(result.parameters.count, 2)
        XCTAssertEqual(result.steps.count, 1)
        XCTAssertEqual(result.steps[0].parameters.count, 2)
        XCTAssertEqual(result.steps[0].parameters[0].id, paramOne.id)
        XCTAssertEqual(result.steps[0].parameters[1].id, paramTwo.id)
        XCTAssertNil(result.steps[0].back)
    }
    
    func testAppendingStep_Second_Correct() throws {
        
        // given
        let paramOne = Payments.ParameterMock(id: "one", value: "100")
        let paramTwo = Payments.ParameterMock(id: "two", value: "200")
        let stepFirst = Payments.Operation.Step(parameters: [paramOne, paramTwo], front: .init(visible: [], isCompleted: false), back: nil)
        let operation = Payments.Operation(service: .fms, source: .none, steps: [stepFirst])
        
        let paramThree = Payments.ParameterMock(id: "three", value: "300")
        let terms: [Payments.Operation.Step.Term] = [.init(parameterId: paramThree.id, impact: .rollback)]
        let stepSecond = Payments.Operation.Step(parameters: [paramThree], front: .init(visible: [], isCompleted: false), back: .init(stage: .start, terms: terms, processed: nil))
        
        // when
        let result = try operation.appending(step: stepSecond)
        
        // then
        XCTAssertEqual(result.parameters.count, 3)
        XCTAssertEqual(result.steps.count, 2)
    }
    
    func testAppendingStep_Duplicate_Param_Incorrect() throws {
        
        // given
        let paramOne = Payments.ParameterMock(id: "one", value: "100")
        let paramTwo = Payments.ParameterMock(id: "two", value: "200")
        let stepFirst = Payments.Operation.Step(parameters: [paramOne, paramTwo], front: .init(visible: [], isCompleted: false), back: nil)
        let operation = Payments.Operation(service: .fms, source: .none, steps: [stepFirst])
        
        let paramThree = Payments.ParameterMock(id: "one", value: "300")
        let stepSecond = Payments.Operation.Step(parameters: [paramThree], front: .init(visible: [], isCompleted: false), back: nil)
        
        // when
        XCTAssertThrowsError( try operation.appending(step: stepSecond))
    }
    
    func testAppendingStep_Duplicate_Visible_Incorrect() throws {
        
        // given
        let paramOne = Payments.ParameterMock(id: "one", value: "100")
        let paramTwo = Payments.ParameterMock(id: "two", value: "200")
        let stepFirst = Payments.Operation.Step(parameters: [paramOne, paramTwo], front: .init(visible: ["one"], isCompleted: false), back: nil)
        let operation = Payments.Operation(service: .fms, source: .none, steps: [stepFirst])
        
        let paramThree = Payments.ParameterMock(id: "three", value: "300")
        let stepSecond = Payments.Operation.Step(parameters: [paramThree], front: .init(visible: ["one"], isCompleted: false), back: nil)
        
        // when
        XCTAssertThrowsError( try operation.appending(step: stepSecond))
    }
    
    func testAppendingStep_Terms_Incorrect() throws {
        
        // given
        let paramOne = Payments.ParameterMock(id: "one", value: "100")
        let paramTwo = Payments.ParameterMock(id: "two", value: "200")
        let stepFirst = Payments.Operation.Step(parameters: [paramOne, paramTwo], front: .init(visible: ["one"], isCompleted: false), back: nil)
        let operation = Payments.Operation(service: .fms, source: .none, steps: [stepFirst])
        
        let paramThree = Payments.ParameterMock(id: "three", value: "300")
        let terms: [Payments.Operation.Step.Term] = [.init(parameterId: "unknown", impact: .rollback)]
        let stepSecond = Payments.Operation.Step(parameters: [paramThree], front: .init(visible: ["three"], isCompleted: false), back: .init(stage: .start, terms: terms, processed: nil))
        
        // when
        XCTAssertThrowsError( try operation.appending(step: stepSecond))
    }
}

//MARK: - Updated

extension PaymentsOperationTests {
    
    func testUpdated_Correct() throws {
        
        // given
        let paramOne = Payments.ParameterMock(id: "one", value: "100")
        let paramTwo = Payments.ParameterMock(id: "two", value: nil)
        let stepOne = Payments.Operation.Step(parameters: [paramOne, paramTwo], front: .init(visible: [], isCompleted: false), back: nil)
        
        let paramThree = Payments.ParameterMock(id: "three", value: "300")
        let stepTwo = Payments.Operation.Step(parameters: [paramThree], front: .init(visible: [], isCompleted: true), back: nil)
        
        let operation = Payments.Operation(service: .fms, source: .none, steps: [stepOne, stepTwo])
        let updateOne = Payments.Parameter(id: "one", value: "100")
        let updateTwo = Payments.Parameter(id: "two", value: "300")
        let updateThree = Payments.Parameter(id: "three", value: "400")
        
        // when
        let result = operation.updated(with: [updateOne, updateTwo, updateThree])
        
        // then
        XCTAssertEqual(result.parameters.count, 3)
        XCTAssertEqual(result.parameters[0].value, "100")
        XCTAssertEqual(result.parameters[1].value, "300")
        XCTAssertEqual(result.parameters[2].value, "400")
        XCTAssertEqual(result.steps[0].front.isCompleted, true)
        XCTAssertEqual(result.steps[1].front.isCompleted, true)
    }
    
    func testUpdated_Unexpected_No_Change() throws {
        
        // given
        let paramOne = Payments.ParameterMock(id: "one", value: "100")
        let paramTwo = Payments.ParameterMock(id: "two", value: "200")
        let step = Payments.Operation.Step(parameters: [paramOne, paramTwo], front: .init(visible: [], isCompleted: true), back: nil)
        let operation = Payments.Operation(service: .fms, source: .none, steps: [step])
        let update = Payments.Parameter(id: "unexpected", value: "300")
        
        // when
        let result = operation.updated(with: [update])
        
        // then
        XCTAssertEqual(result.parameters.count, 2)
        XCTAssertEqual(result.parameters[0].value, paramOne.value)
        XCTAssertEqual(result.parameters[1].value, paramTwo.value)
        XCTAssertEqual(result.steps[0].front.isCompleted, step.front.isCompleted)
    }
}

//MARK: - Rollback

extension PaymentsOperationTests {
    
    func testRollback_Correct() throws {
        
        // given
        let paramOne = Payments.ParameterMock(id: "one", value: "100")
        let stepOne = Payments.Operation.Step(parameters: [paramOne], front: .init(visible: ["one"], isCompleted: true), back: .init(stage: .start, terms: [.init(parameterId: paramOne.id, impact: .rollback)], processed: [paramOne.parameter]))

        let paramTwo = Payments.ParameterMock(id: "two", value: "200")
        let stepTwo = Payments.Operation.Step(parameters: [paramTwo], front: .init(visible: ["two"], isCompleted: true), back: .init(stage: .next, terms:[.init(parameterId: paramTwo.id, impact: .restart)], processed: [paramTwo.parameter]))
        
        let paramThree = Payments.ParameterMock(id: "three", value: "300")
        let stepThree = Payments.Operation.Step(parameters: [paramThree], front: .init(visible: [], isCompleted: true), back: .init(stage: .complete, terms: [.init(parameterId: paramThree.id, impact: .rollback)], processed: [paramThree.parameter]))

        let operation = Payments.Operation(service: .fms, source: .none, steps: [stepOne, stepTwo, stepThree])
        
        // when
        let result = try operation.rollback(to: 1)
        
        // then
        XCTAssertEqual(result.steps.count, 2)
        
        // step one
        XCTAssertEqual(result.steps[0].parameters.count, 1)
        XCTAssertEqual(result.steps[0].parameters[0].id, paramOne.id)
        XCTAssertEqual(result.steps[0].parameters[0].value, paramOne.value)
        XCTAssertEqual(result.steps[0].front, stepOne.front)
        XCTAssertNotNil(result.steps[0].back)
        XCTAssertEqual(result.steps[0].back!.stage, .start)
        XCTAssertEqual(result.steps[0].back!.terms, stepOne.back?.terms)
        XCTAssertNil(result.steps[0].back!.processed)
        
        // step two
        XCTAssertEqual(result.steps[1].parameters.count, 1)
        XCTAssertEqual(result.steps[1].parameters[0].id, paramTwo.id)
        XCTAssertEqual(result.steps[1].parameters[0].value, paramTwo.value)
        XCTAssertEqual(result.steps[1].front, stepTwo.front)
        XCTAssertNotNil(result.steps[1].back)
        XCTAssertEqual(result.steps[1].back!.stage, .next)
        XCTAssertEqual(result.steps[1].back!.terms, stepTwo.back?.terms)
        XCTAssertNil(result.steps[1].back!.processed)
    }
    
    func testRollback_Step_Index_Incorrect() throws {
        
        // given
        let paramOne = Payments.ParameterMock(id: "one", value: "100")
        let stepOne = Payments.Operation.Step(parameters: [paramOne], front: .init(visible: ["one"], isCompleted: true), back: .init(stage: .start, terms: [.init(parameterId: paramOne.id, impact: .rollback)], processed: [paramOne.parameter]))

        let paramTwo = Payments.ParameterMock(id: "two", value: "200")
        let stepTwo = Payments.Operation.Step(parameters: [paramTwo], front: .init(visible: ["two"], isCompleted: true), back: .init(stage: .next, terms:[.init(parameterId: paramTwo.id, impact: .restart)], processed: [paramTwo.parameter]))
        
        let paramThree = Payments.ParameterMock(id: "three", value: "300")
        let stepThree = Payments.Operation.Step(parameters: [paramThree], front: .init(visible: [], isCompleted: true), back: .init(stage: .complete, terms: [.init(parameterId: paramThree.id, impact: .rollback)], processed: [paramThree.parameter]))

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
        let stepOne = Payments.Operation.Step(parameters: [paramOne], front: .init(visible: ["one"], isCompleted: true), back: .init(stage: .start, terms: [.init(parameterId: paramOne.id, impact: .rollback)], processed: [paramOne.parameter]))

        let paramTwo = Payments.ParameterMock(id: "two", value: "200")
        let stepTwo = Payments.Operation.Step(parameters: [paramTwo], front: .init(visible: ["two"], isCompleted: true), back: .init(stage: .next, terms:[.init(parameterId: paramTwo.id, impact: .restart)], processed: [paramTwo.parameter]))
        
        let paramThree = Payments.ParameterMock(id: "three", value: "300")
        let stepThree = Payments.Operation.Step(parameters: [paramThree], front: .init(visible: [], isCompleted: true), back: .init(stage: .complete, terms: [.init(parameterId: paramThree.id, impact: .rollback)], processed: nil))

        let operation = Payments.Operation(service: .fms, source: .none, steps: [stepOne, stepTwo, stepThree])
        
        // when
        let result = try operation.processed(parameters: [paramThree.parameter], stepIndex: 2)
        
        // then
        XCTAssertEqual(result.steps[0].back, stepOne.back)
        XCTAssertEqual(result.steps[1].back, stepTwo.back)
        XCTAssertNotNil(result.steps[2].back?.processed)
        XCTAssertEqual(result.steps[2].back!.processed!.count, 1)
        XCTAssertEqual(result.steps[2].back!.processed![0].id, paramThree.id)
        XCTAssertEqual(result.steps[2].back!.processed![0].value, paramThree.value)
    }
    
    func testProcessed_Step_Index_Out_Of_Range() throws {
        
        // given
        let paramOne = Payments.ParameterMock(id: "one", value: "100")
        let stepOne = Payments.Operation.Step(parameters: [paramOne], front: .init(visible: ["one"], isCompleted: true), back: .init(stage: .start, terms: [.init(parameterId: paramOne.id, impact: .rollback)], processed: [paramOne.parameter]))
        let operation = Payments.Operation(service: .fms, source: .none, steps: [stepOne])
        
        // then
        XCTAssertThrowsError(try operation.processed(parameters: [paramOne.parameter], stepIndex: 2))
       
    }
}

//MARK: - Next Action

extension PaymentsOperationTests {
    
    func testNextAction_Params_For_Step_0() throws {
        
        // given
        let operation = Payments.Operation(service: .fms, source: .none, steps: [])
        
        // when
        let result = operation.nextAction()
        
        // then
        XCTAssertEqual(result, .step(index: 0))
    }
    
    func testNextAction_Front_Update() throws {
        
        // given
        let paramOne = Payments.ParameterMock(id: "one", value: nil)
        let stepOne = Payments.Operation.Step(parameters: [paramOne], front: .init(visible: ["one"], isCompleted: false), back: .init(stage: .start, terms: [.init(parameterId: paramOne.id, impact: .rollback)], processed: nil))

        let operation = Payments.Operation(service: .fms, source: .none, steps: [stepOne])
        
        // when
        let result = operation.nextAction()
        
        // then
        XCTAssertEqual(result, .frontUpdate)
    }
    
    func testNextAction_Process_Params() throws {
        
        // given
        let paramOne = Payments.ParameterMock(id: "one", value: "100")
        let stepOne = Payments.Operation.Step(parameters: [paramOne], front: .init(visible: ["one"], isCompleted: true), back: .init(stage: .start, terms: [.init(parameterId: paramOne.id, impact: .rollback)], processed: nil))

        let operation = Payments.Operation(service: .fms, source: .none, steps: [stepOne])
        
        // when
        let result = operation.nextAction()
        
        // then
        XCTAssertEqual(result, .backProcess(parameters: [paramOne.parameter], stepIndex: 0, stage: .start))
    }
    
    func testNextAction_Next_Front_Update() throws {
        
        // given
        let paramOne = Payments.ParameterMock(id: "one", value: "100")
        let stepOne = Payments.Operation.Step(parameters: [paramOne], front: .init(visible: ["one"], isCompleted: true), back: .init(stage: .start, terms: [.init(parameterId: paramOne.id, impact: .rollback)], processed: [.init(id: "one", value: "100")]))
        
        let paramTwo = Payments.ParameterMock(id: "two", value: nil)
        let stepTwo = Payments.Operation.Step(parameters: [paramTwo], front: .init(visible: ["two"], isCompleted: false), back: .init(stage: .next, terms:[.init(parameterId: paramTwo.id, impact: .restart)], processed: nil))

        let operation = Payments.Operation(service: .fms, source: .none, steps: [stepOne, stepTwo])
        
        // when
        let result = operation.nextAction()
        
        // then
        XCTAssertEqual(result, .frontUpdate)
    }
    
    func testNextAction_Rollback() throws {
        
        // given
        let paramOne = Payments.ParameterMock(id: "one", value: "300")
        let stepOne = Payments.Operation.Step(parameters: [paramOne], front: .init(visible: ["one"], isCompleted: true), back: .init(stage: .start, terms: [.init(parameterId: paramOne.id, impact: .rollback)], processed: [.init(id: "one", value: "100")]))
        
        let paramTwo = Payments.ParameterMock(id: "two", value: "200")
        let stepTwo = Payments.Operation.Step(parameters: [paramTwo], front: .init(visible: ["two"], isCompleted: true), back: .init(stage: .next, terms:[.init(parameterId: paramTwo.id, impact: .restart)], processed: nil))

        let operation = Payments.Operation(service: .fms, source: .none, steps: [stepOne, stepTwo])
        
        // when
        let result = operation.nextAction()
        
        // then
        XCTAssertEqual(result, .rollback(stepIndex: 0))
    }
    
    func testNextAction_Restsrt() throws {
        
        // given
        let paramOne = Payments.ParameterMock(id: "one", value: "100")
        let stepOne = Payments.Operation.Step(parameters: [paramOne], front: .init(visible: ["one"], isCompleted: true), back: .init(stage: .start, terms: [.init(parameterId: paramOne.id, impact: .rollback)], processed: [.init(id: "one", value: "100")]))
        
        let paramTwo = Payments.ParameterMock(id: "two", value: "500")
        let stepTwo = Payments.Operation.Step(parameters: [paramTwo], front: .init(visible: ["two"], isCompleted: true), back: .init(stage: .next, terms:[.init(parameterId: paramTwo.id, impact: .restart)], processed: [.init(id: "two", value: "200")]))

        let operation = Payments.Operation(service: .fms, source: .none, steps: [stepOne, stepTwo])
        
        // when
        let result = operation.nextAction()
        
        // then
        XCTAssertEqual(result, .restart)
    } 
}

//MARK: - Restsrt

extension PaymentsOperationTests {
    
    func testRestart() throws {
        
        // given
        let paramOne = Payments.ParameterMock(id: "one", value: "100")
        let paramTwo = Payments.ParameterMock(id: "two", value: "200")
        let termsOne: [Payments.Operation.Step.Term] = [.init(parameterId: paramTwo.id, impact: .rollback)]
        let paramProcessed = Payments.Parameter(id: "two", value: "300")
        let stepOne = Payments.Operation.Step(parameters: [paramOne, paramTwo], front: .init(visible: [], isCompleted: true), back: .init(stage: .start, terms: termsOne, processed: [paramProcessed]))
        
        let paramThree = Payments.ParameterMock(id: "three", value: "100")
        let termsTwo: [Payments.Operation.Step.Term] = [.init(parameterId: paramThree.id, impact: .rollback)]
        let stepTwo = Payments.Operation.Step(parameters: [paramThree], front: .init(visible: [], isCompleted: true), back: .init(stage: .start, terms: termsTwo, processed: nil))
        
        let operation = Payments.Operation(service: .fms, source: .none, steps: [stepOne, stepTwo])
        
        // when
        let result = operation.restarted()
        
        // then
        XCTAssertEqual(result.steps.count, 2)
        XCTAssertNil(result.steps[0].back?.processed)
        XCTAssertNil(result.steps[1].back?.processed)
    }
}
