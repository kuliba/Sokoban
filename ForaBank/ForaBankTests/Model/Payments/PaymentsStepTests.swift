//
//  PaymentsStepTests.swift
//  ForaBankTests
//
//  Created by Max Gribov on 06.10.2022.
//

import XCTest
@testable import ForaBank

class PaymentsStepTests: XCTestCase {}

//MARK: - Properties

extension PaymentsStepTests {
    
    func testParametersIds() throws {
        
        // given
        let paramOne = Payments.ParameterMock(id: "one", value: "100")
        let paramTwo = Payments.ParameterMock(id: "two", value: "200")
        
        // when
        let result = Payments.Operation.Step(parameters: [paramOne, paramTwo], front: .init(visible: [], isCompleted: false), back: nil)
        
        // then
        XCTAssertEqual(result.parametersIds, ["one", "two"])
    }
}

//MARK: - Contains Parameter ID

extension PaymentsStepTests {
    
    func testContainsParameterId_True() throws {
        
        // given
        let paramOne = Payments.ParameterMock(id: "one", value: "100")
        let paramTwo = Payments.ParameterMock(id: "two", value: "200")
        let step = Payments.Operation.Step(parameters: [paramOne, paramTwo], front: .init(visible: [], isCompleted: false), back: nil)
        
        // when
        let result = step.contains(parameterId: "two")
        
        // then
        XCTAssertTrue(result)
    }
    
    func testContainsParameterId_False() throws {
        
        // given
        let paramOne = Payments.ParameterMock(id: "one", value: "100")
        let paramTwo = Payments.ParameterMock(id: "two", value: "200")
        let step = Payments.Operation.Step(parameters: [paramOne, paramTwo], front: .init(visible: [], isCompleted: false), back: nil)
        
        // when
        let result = step.contains(parameterId: "unexpected")
        
        // then
        XCTAssertFalse(result)
    }
}

//MARK: - Updated

extension PaymentsStepTests {
    
    func testUpdated_Complete() throws {
        
        // given
        let paramOne = Payments.ParameterMock(id: "one", value: "100")
        let paramTwo = Payments.ParameterMock(id: "two", value: nil)
        let step = Payments.Operation.Step(parameters: [paramOne, paramTwo], front: .init(visible: [], isCompleted: false), back: nil)
        let update = Payments.Parameter(id: "two", value: "500")
        
        // when
        let result = step.updated(parameter: update)
        
        // then
        XCTAssertEqual(result.parameters.count, 2)
        XCTAssertEqual(result.parameters[0].value, "100")
        XCTAssertEqual(result.parameters[1].value, "500")
        XCTAssertEqual(result.front.visible, step.front.visible)
        XCTAssertEqual(result.front.isCompleted, true)
        XCTAssertEqual(result.back, step.back)
    }
    
    func testUpdated_Not_Complete() throws {
        
        // given
        let paramOne = Payments.ParameterMock(id: "one", value: nil)
        let paramTwo = Payments.ParameterMock(id: "two", value: nil)
        let step = Payments.Operation.Step(parameters: [paramOne, paramTwo], front: .init(visible: [], isCompleted: false), back: nil)
        let update = Payments.Parameter(id: "two", value: "500")
        
        // when
        let result = step.updated(parameter: update)
        
        // then
        XCTAssertEqual(result.parameters.count, 2)
        XCTAssertNil(result.parameters[0].value)
        XCTAssertEqual(result.parameters[1].value, "500")
        XCTAssertEqual(result.front.visible, step.front.visible)
        XCTAssertEqual(result.front.isCompleted, false)
        XCTAssertEqual(result.back, step.back)
    }
    
    func testUpdated_Not_Contains_Param_Correct() throws {
        
        // given
        let paramOne = Payments.ParameterMock(id: "one", value: "100")
        let paramTwo = Payments.ParameterMock(id: "two", value: "200")
        let step = Payments.Operation.Step(parameters: [paramOne, paramTwo], front: .init(visible: [], isCompleted: true), back: nil)
        let update = Payments.Parameter(id: "four", value: "500")
        
        // when
        let result = step.updated(parameter: update)
        
        // then
        XCTAssertEqual(result.parameters.count, 2)
        XCTAssertEqual(result.parameters[0].value, "100")
        XCTAssertEqual(result.parameters[1].value, "200")
        XCTAssertEqual(result.front, step.front)
        XCTAssertEqual(result.back, step.back)
    }
}

//MARK: - Processed

extension PaymentsStepTests {
    
    func testProcessed_Correct() throws {
        
        // given
        let paramOne = Payments.ParameterMock(id: "one", value: "100")
        let paramTwo = Payments.ParameterMock(id: "two", value: "200")
        let terms: [Payments.Operation.Step.Term] = [.init(parameterId: paramOne.id, impact: .rollback)]
        let step = Payments.Operation.Step(parameters: [paramOne, paramTwo], front: .init(visible: [], isCompleted: false), back: .init(stage: .start, terms: terms, processed: nil))
        let paramProcessed = Payments.Parameter(id: "one", value: "100")
        
        // when
        let result = try step.processed(parameters: [paramProcessed])
        
        // then
        XCTAssertEqual(result.parameters.count, 2)
        XCTAssertEqual(result.parameters[0].value, "100")
        XCTAssertEqual(result.parameters[1].value, "200")
        XCTAssertEqual(result.front, step.front)
        XCTAssertNotNil(result.back)
        XCTAssertEqual(result.back!.stage, step.back!.stage)
        XCTAssertEqual(result.back!.terms, step.back!.terms)
        XCTAssertNotNil(result.back!.processed)
        XCTAssertEqual(result.back!.processed!.count, 1)
        XCTAssertEqual(result.back!.processed![0], paramProcessed)
    }
    
    func testProcessed_Incorrect_Parameter() throws {
        
        // given
        let paramOne = Payments.ParameterMock(id: "one", value: "100")
        let paramTwo = Payments.ParameterMock(id: "two", value: "200")
        let terms: [Payments.Operation.Step.Term] = [.init(parameterId: paramOne.id, impact: .rollback)]
        let step = Payments.Operation.Step(parameters: [paramOne, paramTwo], front: .init(visible: [], isCompleted: false), back: .init(stage: .start, terms: terms, processed: nil))
        let paramProcessed = Payments.Parameter(id: "two", value: "200")
        
        // when
        XCTAssertThrowsError(try step.processed(parameters: [paramProcessed]))
    }
    
    func testProcessed_Incorrect_No_Terms() throws {
        
        // given
        let paramOne = Payments.ParameterMock(id: "one", value: "100")
        let paramTwo = Payments.ParameterMock(id: "two", value: "200")
        let step = Payments.Operation.Step(parameters: [paramOne, paramTwo], front: .init(visible: [], isCompleted: false), back: nil)
        let paramProcessed = Payments.Parameter(id: "two", value: "200")
        
        // when
        XCTAssertThrowsError(try step.processed(parameters: [paramProcessed]))
    }
}

//MARK: - Reseted

extension PaymentsStepTests {
    
    func testReseted_Correct() throws {
        
        // given
        let paramOne = Payments.ParameterMock(id: "one", value: "100")
        let paramTwo = Payments.ParameterMock(id: "two", value: "200")
        let terms: [Payments.Operation.Step.Term] = [.init(parameterId: paramOne.id, impact: .rollback)]
        let paramProcessed = Payments.Parameter(id: "one", value: "100")
        let step = Payments.Operation.Step(parameters: [paramOne, paramTwo], front: .init(visible: [], isCompleted: false), back: .init(stage: .start, terms: terms, processed: [paramProcessed]))
        
        // when
        let result = step.reseted()
        
        // then
        XCTAssertEqual(result.parameters.count, 2)
        XCTAssertEqual(result.parameters[0].value, "100")
        XCTAssertEqual(result.parameters[1].value, "200")
        XCTAssertEqual(result.front, step.front)
        XCTAssertNotNil(result.back)
        XCTAssertEqual(result.back!.stage, step.back!.stage)
        XCTAssertEqual(result.back!.terms, step.back!.terms)
        XCTAssertNil(result.back!.processed)
    }
    
    func testReseted_No_Processed_Correct() throws {
        
        // given
        let paramOne = Payments.ParameterMock(id: "one", value: "100")
        let paramTwo = Payments.ParameterMock(id: "two", value: "200")
        let terms: [Payments.Operation.Step.Term] = [.init(parameterId: paramOne.id, impact: .rollback)]
        let step = Payments.Operation.Step(parameters: [paramOne, paramTwo], front: .init(visible: [], isCompleted: false), back: .init(stage: .start, terms: terms, processed: nil))
        
        // when
        let result = step.reseted()
        
        // then
        XCTAssertEqual(result.parameters.count, 2)
        XCTAssertEqual(result.parameters[0].value, "100")
        XCTAssertEqual(result.parameters[1].value, "200")
        XCTAssertEqual(result.front, step.front)
        XCTAssertNotNil(result.back)
        XCTAssertEqual(result.back!.stage, step.back!.stage)
        XCTAssertEqual(result.back!.terms, step.back!.terms)
        XCTAssertNil(result.back!.processed)
    }
    
    func testReseted_No_Back_Correct() throws {
        
        // given
        let paramOne = Payments.ParameterMock(id: "one", value: "100")
        let paramTwo = Payments.ParameterMock(id: "two", value: "200")
        let step = Payments.Operation.Step(parameters: [paramOne, paramTwo], front: .init(visible: [], isCompleted: false), back: nil)
        
        // when
        let result = step.reseted()
        
        // then
        XCTAssertEqual(result.parameters.count, 2)
        XCTAssertEqual(result.parameters[0].value, "100")
        XCTAssertEqual(result.parameters[1].value, "200")
        XCTAssertEqual(result.front, step.front)
        XCTAssertNil(result.back)
    }
}

//MARK: - Processed results

extension PaymentsStepTests {
    
    func testProcessedResuts_Correct() throws {
        
        // given
        let paramOne = Payments.ParameterMock(id: "1", value: "100")
        let paramTwo = Payments.ParameterMock(id: "2", value: "200")
        let terms: [Payments.Operation.Step.Term] = [.init(parameterId: paramTwo.id, impact: .restart),.init(parameterId: paramOne.id, impact: .rollback)]
        let paramProcessedOne = Payments.Parameter(id: "1", value: "500")
        let paramProcessedTwo = Payments.Parameter(id: "2", value: "700")
        let step = Payments.Operation.Step(parameters: [paramOne, paramTwo], front: .init(visible: [], isCompleted: false), back: .init(stage: .start, terms: terms, processed: [paramProcessedOne, paramProcessedTwo]))
        let paramTree = Payments.ParameterMock(id: "3", value: "300")
        
        // when
        let result = step.processedResults(with: [paramOne, paramTwo, paramTree])
        
        // then
        XCTAssertNotNil(result)
        XCTAssertEqual(result!.count, 2)
        
        XCTAssertEqual(result![0].current.id, "1")
        XCTAssertEqual(result![0].current.value, "100")
        XCTAssertEqual(result![0].processed.id, "1")
        XCTAssertEqual(result![0].processed.value, "500")
        XCTAssertEqual(result![0].impact, .rollback)
        
        XCTAssertEqual(result![1].current.id, "2")
        XCTAssertEqual(result![1].current.value, "200")
        XCTAssertEqual(result![1].processed.id, "2")
        XCTAssertEqual(result![1].processed.value, "700")
        XCTAssertEqual(result![1].impact, .restart)
    }
    
    func testProcessedResuts_No_Back() throws {
        
        // given
        let paramOne = Payments.ParameterMock(id: "one", value: "100")
        let paramTwo = Payments.ParameterMock(id: "two", value: "200")
        let step = Payments.Operation.Step(parameters: [paramOne, paramTwo], front: .init(visible: [], isCompleted: false), back: nil)
        
        // when
        let result = step.processedResults(with: [paramOne, paramTwo])
        
        // then
        XCTAssertNil(result)
    }
    
    func testProcessedResuts_No_Processed() throws {
        
        // given
        let paramOne = Payments.ParameterMock(id: "one", value: "100")
        let paramTwo = Payments.ParameterMock(id: "two", value: "200")
        let terms: [Payments.Operation.Step.Term] = [.init(parameterId: paramOne.id, impact: .rollback)]
        let step = Payments.Operation.Step(parameters: [paramOne, paramTwo], front: .init(visible: [], isCompleted: false), back: .init(stage: .start, terms: terms, processed: nil))
        
        // when
        let result = step.processedResults(with: [paramOne, paramTwo])
        
        // then
        XCTAssertNil(result)
    }
    
    func testProcessedResuts_Part_Parameters() throws {
        
        // given
        let paramOne = Payments.ParameterMock(id: "1", value: "100")
        let paramTwo = Payments.ParameterMock(id: "2", value: "200")
        let terms: [Payments.Operation.Step.Term] = [.init(parameterId: paramTwo.id, impact: .restart),.init(parameterId: paramOne.id, impact: .rollback)]
        let paramProcessedOne = Payments.Parameter(id: "1", value: "500")
        let paramProcessedTwo = Payments.Parameter(id: "2", value: "700")
        let step = Payments.Operation.Step(parameters: [paramOne, paramTwo], front: .init(visible: [], isCompleted: false), back: .init(stage: .start, terms: terms, processed: [paramProcessedOne, paramProcessedTwo]))
 
        // when
        let result = step.processedResults(with: [paramOne])
        
        // then
        XCTAssertNotNil(result)
        XCTAssertEqual(result!.count, 1)
        
        XCTAssertEqual(result![0].current.id, "1")
        XCTAssertEqual(result![0].current.value, "100")
        XCTAssertEqual(result![0].processed.id, "1")
        XCTAssertEqual(result![0].processed.value, "500")
        XCTAssertEqual(result![0].impact, .rollback)
    }
    
    func testProcessedResuts_Not_Existing_Param() throws {
        
        // given
        let paramOne = Payments.ParameterMock(id: "1", value: "100")
        let paramTwo = Payments.ParameterMock(id: "2", value: "200")
        let terms: [Payments.Operation.Step.Term] = [.init(parameterId: paramTwo.id, impact: .restart),.init(parameterId: paramOne.id, impact: .rollback)]
        let paramProcessedOne = Payments.Parameter(id: "1", value: "500")
        let paramProcessedTwo = Payments.Parameter(id: "2", value: "700")
        let step = Payments.Operation.Step(parameters: [paramOne, paramTwo], front: .init(visible: [], isCompleted: false), back: .init(stage: .start, terms: terms, processed: [paramProcessedOne, paramProcessedTwo]))
        let paramTree = Payments.ParameterMock(id: "3", value: "300")
        
        // when
        let result = step.processedResults(with: [paramTree])
        
        // then
        XCTAssertNil(result)
    }
}

//MARK: - Status

extension PaymentsStepTests {
    
    func testStatus_Editing() throws {
        
        // given
        let paramOne = Payments.ParameterMock(id: "one", value: "100")
        let paramTwo = Payments.ParameterMock(id: "two", value: nil)
        let step = Payments.Operation.Step(parameters: [paramOne, paramTwo], front: .init(visible: [], isCompleted: false), back: nil)
        
        // when
        let result = step.status(with: [paramOne, paramTwo])
        
        // then
        XCTAssertEqual(result, .editing)
    }
    
    func testStatus_No_Back_Complete() throws {
        
        // given
        let paramOne = Payments.ParameterMock(id: "one", value: "100")
        let paramTwo = Payments.ParameterMock(id: "two", value: "300")
        let step = Payments.Operation.Step(parameters: [paramOne, paramTwo], front: .init(visible: [], isCompleted: true), back: nil)
        
        // when
        let result = step.status(with: [paramOne, paramTwo])
        
        // then
        XCTAssertEqual(result, .complete)
    }
    
    func testStatus_Pending() throws {
        
        // given
        let paramOne = Payments.ParameterMock(id: "one", value: "100")
        let paramTwo = Payments.ParameterMock(id: "two", value: "200")
        let terms: [Payments.Operation.Step.Term] = [.init(parameterId: paramOne.id, impact: .rollback)]
        let step = Payments.Operation.Step(parameters: [paramOne, paramTwo], front: .init(visible: [], isCompleted: true), back: .init(stage: .start, terms: terms, processed: nil))

        // when
        let result = step.status(with: [paramOne, paramTwo])
        
        XCTAssertEqual(result, .pending(parameters: [.init(id: "one", value: "100")], stage: .start))
    }
    
    func testStatus_Back_Complete() throws {
        
        // given
        let paramOne = Payments.ParameterMock(id: "1", value: "100")
        let paramTwo = Payments.ParameterMock(id: "2", value: "200")
        let terms: [Payments.Operation.Step.Term] = [.init(parameterId: paramTwo.id, impact: .restart),.init(parameterId: paramOne.id, impact: .rollback)]
        let paramProcessedOne = Payments.Parameter(id: "1", value: "100")
        let paramProcessedTwo = Payments.Parameter(id: "2", value: "200")
        let step = Payments.Operation.Step(parameters: [paramOne, paramTwo], front: .init(visible: [], isCompleted: true), back: .init(stage: .start, terms: terms, processed: [paramProcessedOne, paramProcessedTwo]))
        
        // when
        let result = step.status(with: [paramOne, paramTwo])
        
        // then
        XCTAssertEqual(result, .complete)
    }
    
    func testStatus_Back_Invalidated() throws {
        
        // given
        let paramOne = Payments.ParameterMock(id: "1", value: "100")
        let paramTwo = Payments.ParameterMock(id: "2", value: "200")
        let terms: [Payments.Operation.Step.Term] = [.init(parameterId: paramTwo.id, impact: .restart),.init(parameterId: paramOne.id, impact: .rollback)]
        let paramProcessedOne = Payments.Parameter(id: "1", value: "300")
        let paramProcessedTwo = Payments.Parameter(id: "2", value: "200")
        let step = Payments.Operation.Step(parameters: [paramOne, paramTwo], front: .init(visible: [], isCompleted: true), back: .init(stage: .start, terms: terms, processed: [paramProcessedOne, paramProcessedTwo]))
        
        // when
        let result = step.status(with: [paramOne, paramTwo])
        
        // then
        XCTAssertEqual(result, .invalidated(.rollback))
    }
    
    func testStatus_Multiple_Impacts_Invalidated() throws {
        
        // given
        let paramOne = Payments.ParameterMock(id: "1", value: "100")
        let paramTwo = Payments.ParameterMock(id: "2", value: "200")
        let terms: [Payments.Operation.Step.Term] = [.init(parameterId: paramTwo.id, impact: .restart),.init(parameterId: paramOne.id, impact: .rollback)]
        let paramProcessedOne = Payments.Parameter(id: "1", value: "300")
        let paramProcessedTwo = Payments.Parameter(id: "2", value: "500")
        let step = Payments.Operation.Step(parameters: [paramOne, paramTwo], front: .init(visible: [], isCompleted: true), back: .init(stage: .start, terms: terms, processed: [paramProcessedOne, paramProcessedTwo]))
        
        // when
        let result = step.status(with: [paramOne, paramTwo])
        
        // then
        XCTAssertEqual(result, .invalidated(.rollback))
    }
        
}
