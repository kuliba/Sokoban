//
//  PaymentsProcessTests.swift
//  ForaBankTests
//
//  Created by Max Gribov on 26.10.2022.
//

import XCTest
@testable import ForaBank

class PaymentsProcessTests: XCTestCase {
    
    
}

extension PaymentsProcessTests {
    
    func testInitial_Second_Step() async throws {
        
        // given
        let service: Payments.Service = .fns
        let operation = Payments.Operation(service: service)

        // when
        let result = try await process(operation)
        
        // then
        guard case .step(let resultOperation) = result else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(resultOperation.steps.count, 2)
        
        let firstStepResult = resultOperation.steps[0]
        XCTAssertEqual(firstStepResult.back.processed, [.init(id: "operator", value: "fns")])
        
        let secondStepResult = resultOperation.steps[1]
        XCTAssertEqual(secondStepResult.parameters.count, 1)
        XCTAssertEqual(secondStepResult.parameters[0].id, "service")
    }
    
    func testFirstStep_Rollback() async throws {
        
        // given
        let service: Payments.Service = .fns
        let operation = Payments.Operation(service: service)
        let resultSecondStep = try await process(operation)
        guard case .step(let operationSecondStep) = resultSecondStep else {
            XCTFail()
            return
        }
        // user in UI changed operator
        let operationSecondStepUpdated = operationSecondStep.updated(with: [.init(id: "operator", value: "fnsUin")])
        
        // when
        let result = try await process(operationSecondStepUpdated)
 
        // then
        guard case .step(let resultOperation) = result else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(resultOperation.steps.count, 2)
        
        let firstStepResult = resultOperation.steps[0]
        XCTAssertEqual(firstStepResult.parameters[0].value, "fnsUin")
        XCTAssertEqual(firstStepResult.back.processed, [.init(id: "operator", value: "fnsUin")])
        
        let secondStepResult = resultOperation.steps[1]
        XCTAssertEqual(secondStepResult.parameters.count, 1)
        XCTAssertEqual(secondStepResult.parameters[0].id, "uin")
        XCTAssertNil(secondStepResult.parameters[0].value)
    }
}

extension PaymentsProcessTests {
    
    func process(_ operation: Payments.Operation) async throws -> Payments.ProcessResult {
        
        try await Model.paymentsProcess(operation: operation,
                              localStep: localStep(service:stepIndex:operation:),
                              remoteStep: remoteStep(operation:response:),
                              remoteStart: remoteStart(parameters:operation:),
                              remoteNext: remoteNext(parameters:operation:),
                              remoteConfirm: remoteConfirm(parameters:operation:),
                              remoteComplete: remoteComplete(parameters:operation:),
                              sourceReducer: sourceReducer(service:source:parameter:),
                              dependenceReducer: dependenceReducer(parameterId:parameters:))
    }
}


private func localStep(service: Payments.Service, stepIndex: Int, operation: Payments.Operation) async throws -> Payments.Operation.Step {
    
    switch service {
    case .fns:
        switch stepIndex {
        case 0:
            let paramOperator = Payments.ParameterMock(id: "operator", value: "fns")
            return .init(parameters: [paramOperator], front: .init(visible: [paramOperator.id], isCompleted: true), back: .init(stage: .local, terms: [.init(parameterId: "operator", impact: .rollback)], processed: nil))
        case 1:
            guard let paramOperatorValue = operation.parameters.first(where: { $0.id == "operator" })?.value else {
                throw Payments.Error.missingParameter
            }
            switch paramOperatorValue {
            case "fns":
                let paramService = Payments.ParameterMock(id: "service", value: "1")
                return .init(parameters: [paramService], front: .init(visible: [paramService.id], isCompleted: false), back: .init(stage: .remote(.start), terms: [.init(parameterId: "service", impact: .rollback)], processed: nil))
                
            case "fnsUin":
                let paramUin = Payments.ParameterMock(id: "uin", value: nil)
                return .init(parameters: [paramUin], front: .init(visible: [paramUin.id], isCompleted: false), back: .init(stage: .remote(.start), terms: [.init(parameterId: "uin", impact: .rollback)], processed: nil))
                
            default:
                throw Payments.Error.unexpectedOperatorValue
            }
            
        default:
            throw Payments.Error.unsupported
            
        }

    default:
        throw Payments.Error.unsupported
    }
}

private func remoteStep(operation: Payments.Operation, response: TransferResponseData) async throws -> Payments.Operation.Step {
    
    throw Payments.Error.unsupported
}

private func remoteStart(parameters: [Payments.Parameter], operation: Payments.Operation) async throws -> TransferResponseData {
    
    throw Payments.Error.unsupported
}

private func remoteNext(parameters: [Payments.Parameter], operation: Payments.Operation) async throws -> TransferResponseData {
    
    throw Payments.Error.unsupported
}

private func remoteConfirm(parameters: [Payments.Parameter], operation: Payments.Operation) async throws -> Payments.Success {
    
    throw Payments.Error.unsupported
}

private func remoteComplete(parameters: [Payments.Parameter], operation: Payments.Operation) async throws -> Payments.Success {
    
    throw Payments.Error.unsupported
}

private func sourceReducer(service: Payments.Service, source: Payments.Operation.Source, parameter: Payments.Parameter.ID) -> Payments.Parameter.Value? {
    
    return nil
}

private func dependenceReducer(parameterId: Payments.Parameter.ID, parameters: [PaymentsParameterRepresentable]) -> PaymentsParameterRepresentable? {
    
    return nil
}
