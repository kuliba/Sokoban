//
//  PaymentsProcessTests.swift
//  ForaBankTests
//
//  Created by Max Gribov on 26.10.2022.
//

import XCTest
@testable import ForaBank

final class PaymentsProcessTests: XCTestCase {

    func testLocalMultistep_FirstStep_AutoComplete() async throws {
        
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
    
    func testLocalMultistep_FirstStep_Rollback() async throws {
        
        // given
        
        /// MODEL
        let service: Payments.Service = .fns
        let operation = Payments.Operation(service: service)
        let peocessResult = try await process(operation)
        guard case .step(let operationSecondStep) = peocessResult else {
            XCTFail()
            return
        }
        /// UI
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
    
    func testRemoteMultistep() async throws {
 
        /// MODEL
        let service: Payments.Service = .fns
        let operation = Payments.Operation(service: service)
        let processResultOne = try await process(operation)
        guard case .step(let operationStepOne) = processResultOne else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(operationStepOne.steps[0].parameters[0].parameter, .init(id: "operator", value: "fns"))
        XCTAssertEqual(operationStepOne.steps[1].parameters[0].parameter, .init(id: "service", value: nil))
        
        /// UI
        let operationStepOneUpdated = operationStepOne.updated(with: [.init(id: "service", value: "1")])
        
        XCTAssertEqual(operationStepOneUpdated.steps[0].parameters[0].parameter, .init(id: "operator", value: "fns"))
        XCTAssertEqual(operationStepOneUpdated.steps[1].parameters[0].parameter, .init(id: "service", value: "1"))
        
        /// MODEL
        let processResultTwo = try await process(operationStepOneUpdated)
        guard case .step(let operationStepTwo) = processResultTwo else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(operationStepTwo.steps[0].parameters[0].parameter, .init(id: "operator", value: "fns"))
        XCTAssertEqual(operationStepTwo.steps[1].parameters[0].parameter, .init(id: "service", value: "1"))
        XCTAssertEqual(operationStepTwo.steps[2].parameters[0].parameter, .init(id: "inn", value: nil))
        
        /// UI
        let operationStepTwoUpdated = operationStepTwo.updated(with: [.init(id: "inn", value: "234")])
        
        XCTAssertEqual(operationStepTwoUpdated.steps[0].parameters[0].parameter, .init(id: "operator", value: "fns"))
        XCTAssertEqual(operationStepTwoUpdated.steps[1].parameters[0].parameter, .init(id: "service", value: "1"))
        XCTAssertEqual(operationStepTwoUpdated.steps[2].parameters[0].parameter, .init(id: "inn", value: "234"))
        
        /// MODEL
        let processResultThree = try await process(operationStepTwoUpdated)
        guard case .confirm(let operationStepThree) = processResultThree else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(operationStepThree.steps[0].parameters[0].parameter, .init(id: "operator", value: "fns"))
        XCTAssertEqual(operationStepThree.steps[1].parameters[0].parameter, .init(id: "service", value: "1"))
        XCTAssertEqual(operationStepThree.steps[2].parameters[0].parameter, .init(id: "inn", value: "234"))
        XCTAssertEqual(operationStepThree.steps[3].parameters[0].parameter, .init(id: "amount", value: "0"))
        XCTAssertEqual(operationStepThree.steps[3].parameters[1].parameter, .init(id: "code", value: nil))
        
        /// UI
        let operationStepThreeUpdated = operationStepThree.updated(with: [.init(id: "code", value: "789"), .init(id: "amount", value: "100")])
        
        XCTAssertEqual(operationStepThreeUpdated.steps[0].parameters[0].parameter, .init(id: "operator", value: "fns"))
        XCTAssertEqual(operationStepThreeUpdated.steps[1].parameters[0].parameter, .init(id: "service", value: "1"))
        XCTAssertEqual(operationStepThreeUpdated.steps[2].parameters[0].parameter, .init(id: "inn", value: "234"))
        XCTAssertEqual(operationStepThreeUpdated.steps[3].parameters[0].parameter, .init(id: "amount", value: "100"))
        XCTAssertEqual(operationStepThreeUpdated.steps[3].parameters[1].parameter, .init(id: "code", value: "789"))
        
        /// MODEL
        let processResultFour = try await process(operationStepThreeUpdated)
        guard case .complete(let success) = processResultFour else {
            XCTFail()
            return
        }
        
        /// UI
        XCTAssertEqual(success.status, .complete)
    }
    
    func testRemoteMultistep_Rollback() async throws {
 
        /// MODEL
        let service: Payments.Service = .fns
        let operation = Payments.Operation(service: service)
        let processResultOne = try await process(operation)
        guard case .step(let operationStepOne) = processResultOne else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(operationStepOne.steps[0].parameters[0].parameter, .init(id: "operator", value: "fns"))
        XCTAssertEqual(operationStepOne.steps[1].parameters[0].parameter, .init(id: "service", value: nil))
        
        /// UI
        let operationStepOneUpdated = operationStepOne.updated(with: [.init(id: "service", value: "1")])
        
        XCTAssertEqual(operationStepOneUpdated.steps[0].parameters[0].parameter, .init(id: "operator", value: "fns"))
        XCTAssertEqual(operationStepOneUpdated.steps[1].parameters[0].parameter, .init(id: "service", value: "1"))
        
        /// MODEL
        let processResultTwo = try await process(operationStepOneUpdated)
        guard case .step(let operationStepTwo) = processResultTwo else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(operationStepTwo.steps[0].parameters[0].parameter, .init(id: "operator", value: "fns"))
        XCTAssertEqual(operationStepTwo.steps[1].parameters[0].parameter, .init(id: "service", value: "1"))
        XCTAssertEqual(operationStepTwo.steps[2].parameters[0].parameter, .init(id: "inn", value: nil))
        
        /// UI
        let operationStepTwoUpdated = operationStepTwo.updated(with: [.init(id: "inn", value: "234")])
        
        XCTAssertEqual(operationStepTwoUpdated.steps[0].parameters[0].parameter, .init(id: "operator", value: "fns"))
        XCTAssertEqual(operationStepTwoUpdated.steps[1].parameters[0].parameter, .init(id: "service", value: "1"))
        XCTAssertEqual(operationStepTwoUpdated.steps[2].parameters[0].parameter, .init(id: "inn", value: "234"))
        
        /// MODEL
        let processResultThree = try await process(operationStepTwoUpdated)
        guard case .confirm(let operationStepThree) = processResultThree else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(operationStepThree.steps[0].parameters[0].parameter, .init(id: "operator", value: "fns"))
        XCTAssertEqual(operationStepThree.steps[1].parameters[0].parameter, .init(id: "service", value: "1"))
        XCTAssertEqual(operationStepThree.steps[2].parameters[0].parameter, .init(id: "inn", value: "234"))
        XCTAssertEqual(operationStepThree.steps[3].parameters[0].parameter, .init(id: "amount", value: "0"))
        XCTAssertEqual(operationStepThree.steps[3].parameters[1].parameter, .init(id: "code", value: nil))
        
        /// UI ROLLBACK
        let operationStepThreeUpdated = operationStepThree.updated(with: [.init(id: "operator", value: "fnsUin")])
        
        XCTAssertEqual(operationStepThreeUpdated.steps[0].parameters[0].parameter, .init(id: "operator", value: "fnsUin"))
        XCTAssertEqual(operationStepThreeUpdated.steps[1].parameters[0].parameter, .init(id: "service", value: "1"))
        XCTAssertEqual(operationStepThreeUpdated.steps[2].parameters[0].parameter, .init(id: "inn", value: "234"))
        XCTAssertEqual(operationStepThreeUpdated.steps[3].parameters[0].parameter, .init(id: "amount", value: "0"))
        XCTAssertEqual(operationStepThreeUpdated.steps[3].parameters[1].parameter, .init(id: "code", value: nil))
        
        /// MODEL
        let processResultFour = try await process(operationStepThreeUpdated)
        guard case .step(let operationStepFour) = processResultFour else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(operationStepFour.steps[0].parameters[0].parameter, .init(id: "operator", value: "fnsUin"))
        XCTAssertEqual(operationStepFour.steps[1].parameters[0].parameter, .init(id: "uin", value: nil))
        
        /// UI
        let operationStepFourUpdated = operationStepFour.updated(with: [.init(id: "uin", value: "123")])
        
        XCTAssertEqual(operationStepFourUpdated.steps[0].parameters[0].parameter, .init(id: "operator", value: "fnsUin"))
        XCTAssertEqual(operationStepFourUpdated.steps[1].parameters[0].parameter, .init(id: "uin", value: "123"))
        
        /// MODEL
        let processResultFive = try await process(operationStepFourUpdated)
        guard case .step(let operationStepFive) = processResultFive else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(operationStepFive.steps[0].parameters[0].parameter, .init(id: "operator", value: "fnsUin"))
        XCTAssertEqual(operationStepFive.steps[1].parameters[0].parameter, .init(id: "uin", value: "123"))
        XCTAssertEqual(operationStepFive.steps[2].parameters[0].parameter, .init(id: "bic", value: nil))
        
        /// UI
        let operationStepFiveUpdated = operationStepFive.updated(with: [.init(id: "bic", value: "123")])
        
        XCTAssertEqual(operationStepFiveUpdated.steps[0].parameters[0].parameter, .init(id: "operator", value: "fnsUin"))
        XCTAssertEqual(operationStepFiveUpdated.steps[1].parameters[0].parameter, .init(id: "uin", value: "123"))
        XCTAssertEqual(operationStepFiveUpdated.steps[2].parameters[0].parameter, .init(id: "bic", value: "123"))
        
        /// MODEL
        let processResultSix = try await process(operationStepFiveUpdated)
        guard case .confirm(let operationStepSix) = processResultSix else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(operationStepSix.steps[0].parameters[0].parameter, .init(id: "operator", value: "fnsUin"))
        XCTAssertEqual(operationStepSix.steps[1].parameters[0].parameter, .init(id: "uin", value: "123"))
        XCTAssertEqual(operationStepSix.steps[2].parameters[0].parameter, .init(id: "bic", value: "123"))
        XCTAssertEqual(operationStepSix.steps[3].parameters[0].parameter, .init(id: "amount", value: "0"))
        XCTAssertEqual(operationStepSix.steps[3].parameters[1].parameter, .init(id: "code", value: nil))
        
        /// UI
        let operationStepSixUpdated = operationStepSix.updated(with: [.init(id: "code", value: "555"), .init(id: "amount", value: "200")])
        
        XCTAssertEqual(operationStepSixUpdated.steps[0].parameters[0].parameter, .init(id: "operator", value: "fnsUin"))
        XCTAssertEqual(operationStepSixUpdated.steps[1].parameters[0].parameter, .init(id: "uin", value: "123"))
        XCTAssertEqual(operationStepSixUpdated.steps[2].parameters[0].parameter, .init(id: "bic", value: "123"))
        XCTAssertEqual(operationStepSixUpdated.steps[3].parameters[0].parameter, .init(id: "amount", value: "200"))
        XCTAssertEqual(operationStepSixUpdated.steps[3].parameters[1].parameter, .init(id: "code", value: "555"))
        
        /// MODEL
        let processResultSeven = try await process(operationStepSixUpdated)
        guard case .complete(let success) = processResultSeven else {
            XCTFail()
            return
        }
        
        /// UI
        XCTAssertEqual(success.status, .complete)
    }
}

extension PaymentsProcessTests {
    
    func process(_ operation: Payments.Operation) async throws -> Payments.ProcessResult {
        
        try await Model.paymentsProcess(operation: operation,
                                        localStep: localStep(operation:stepIndex:),
                                        remoteStep: remoteStep(operation:response:),
                                        resetVisible: visibleReducer(operation:),
                                        remoteStart: remoteStart(parameters:operation:),
                                        remoteNext: remoteNext(parameters:operation:),
                                        remoteConfirm: remoteConfirm(parameters:operation:),
                                        remoteComplete: remoteComplete(parameters:operation:),
                                        sourceReducer: sourceReducer(service:source:parameter:),
                                        dependenceReducer: dependenceReducer(operation:parameterId:parameters:))
    }
}


private func localStep(operation: Payments.Operation, stepIndex: Int) async throws -> Payments.Operation.Step {
    
    switch operation.service {
    case .fns:
        switch stepIndex {
        case 0:
            let paramOperator = Payments.ParameterMock(id: "operator", value: "fns")
            return .init(parameters: [paramOperator], front: .init(visible: [paramOperator.id], isCompleted: true), back: .init(stage: .local, required: ["operator"], processed: nil))
        case 1:
            guard let paramOperatorValue = operation.parameters.first(where: { $0.id == "operator" })?.value else {
                throw Payments.Error.missingParameter("operator")
            }
            switch paramOperatorValue {
            case "fns":
                let paramService = Payments.ParameterMock(id: "service", value: nil)
                return .init(parameters: [paramService], front: .init(visible: [paramService.id], isCompleted: false), back: .init(stage: .remote(.start), required: ["service"], processed: nil))
                
            case "fnsUin":
                let paramUin = Payments.ParameterMock(id: "uin", value: nil)
                return .init(parameters: [paramUin], front: .init(visible: [paramUin.id], isCompleted: false), back: .init(stage: .remote(.start), required: ["uin"], processed: nil))
                
            default:
                throw Payments.Error.unsupported
            }
            
        default:
            throw Payments.Error.unsupported
            
        }

    default:
        throw Payments.Error.unsupported
    }
}

private func remoteStep(operation: Payments.Operation, response: TransferResponseData) async throws -> Payments.Operation.Step {
    
    switch operation.service {
    case .fns:
        guard let responseAnyway = response as? TransferAnywayResponseData else {
            throw Payments.Error.unsupported
        }
        var stage = Payments.Operation.Stage.remote(.next)
        var parameters = responseAnyway.parameterListForNextStep.map{ Payments.ParameterMock(id: $0.id, value: $0.content) }
        var required = parameters.map{ $0.id }
        
        if responseAnyway.needSum == true {
            
            parameters.append(Payments.ParameterMock(id: "amount", value: "0"))
            required.append("amount")
        }
        let visible = parameters.map{ $0.id }
        
        if responseAnyway.finalStep == true {
            parameters.append(Payments.ParameterMock(id: "code", value: nil))
            required.append("code")
            stage = .remote(.confirm)
            
        }
        return .init(parameters: parameters, front: .init(visible: visible, isCompleted: false), back: .init(stage: stage, required: required, processed: nil))
        
    default:
        throw Payments.Error.unsupported
    }
}

private func remoteStart(parameters: [Payments.Parameter], operation: Payments.Operation) async throws -> TransferResponseData {
    
    let currentStep = operation.steps.count
    switch operation.service {
    case .fns:
        switch currentStep {
        case 2:
            guard let paramOperatorValue = operation.parameters.first(where: { $0.id == "operator" })?.value else {
                throw Payments.Error.missingParameter("operator")
            }
            switch paramOperatorValue {
            case "fns":
                guard parameters.first(where: { $0.id == "service" })?.value == "1" else {
                    throw Payments.Error.missingParameter("service")
                }
                let parameterInn = ParameterData(id: "inn", value: nil)
                return TransferAnywayResponseData(parameters: [parameterInn], needSum: false, finalStep: false)
                
            case "fnsUin":
                guard parameters.first(where: { $0.id == "uin" })?.value == "123" else {
                    throw Payments.Error.missingParameter("uin")
                }
                let parameterInn = ParameterData(id: "bic", value: nil)
                return TransferAnywayResponseData(parameters: [parameterInn], needSum: false, finalStep: false)
                
            default:
                throw Payments.Error.unsupported
            }
            
        default:
            throw Payments.Error.unsupported
        }
        
    default:
        throw Payments.Error.unsupported
    }
}

private func remoteNext(parameters: [Payments.Parameter], operation: Payments.Operation) async throws -> TransferResponseData {
    
    let currentStep = operation.steps.count
    switch operation.service {
    case .fns:
        switch currentStep {
        case 3:
            guard let paramOperatorValue = operation.parameters.first(where: { $0.id == "operator" })?.value else {
                throw Payments.Error.missingParameter("operator")
            }
            switch paramOperatorValue {
            case "fns":
                guard parameters.first(where: { $0.id == "inn" })?.value == "234" else {
                    throw Payments.Error.missingParameter("inn")
                }
                return TransferAnywayResponseData(parameters: [], needSum: true, finalStep: true)
                
            case "fnsUin":
                guard parameters.first(where: { $0.id == "bic" })?.value == "123" else {
                    throw Payments.Error.missingParameter("bic")
                }
                return TransferAnywayResponseData(parameters: [], needSum: true, finalStep: true)
                
            default:
                throw Payments.Error.unsupported
            }
            
        default:
            throw Payments.Error.unsupported
        }
        
    default:
        throw Payments.Error.unsupported
    }
}

private func remoteConfirm(parameters: [Payments.Parameter], operation: Payments.Operation) async throws -> Payments.Success {
    
    let currentStep = operation.steps.count
    switch operation.service {
    case .fns:
        switch currentStep {
        case 4:
            guard let paramOperatorValue = operation.parameters.first(where: { $0.id == "operator" })?.value else {
                throw Payments.Error.missingParameter("operator")
            }
            switch paramOperatorValue {
            case "fns":
                guard parameters.first(where: { $0.id == "code" })?.value == "789",
                      parameters.first(where: { $0.id == "amount" })?.value == "100" else {
                    throw Payments.Error.missingParameter("code")
                }
                return .init(
                    operation: nil,
                    parameters: [
                    Payments.ParameterSuccessStatus(status: .success)
                ])
                
            case "fnsUin":
                guard parameters.first(where: { $0.id == "code" })?.value == "555",
                      parameters.first(where: { $0.id == "amount" })?.value == "200" else {
                    throw Payments.Error.missingParameter("code")
                }
                return .init(
                    operation: nil,
                    parameters: [
                    Payments.ParameterSuccessStatus(status: .success)
                ])
                
            default:
                throw Payments.Error.unsupported
            }
            
        default:
            throw Payments.Error.unsupported
        }
        
    default:
        throw Payments.Error.unsupported
    }
}

private func remoteComplete(parameters: [Payments.Parameter], operation: Payments.Operation) async throws -> Payments.Success {
    
    throw Payments.Error.unsupported
}

private func sourceReducer(service: Payments.Service, source: Payments.Operation.Source, parameter: Payments.Parameter.ID) -> Payments.Parameter.Value? {
    
    return nil
}

private func dependenceReducer(operation: Payments.Operation, parameterId: Payments.Parameter.ID, parameters: [PaymentsParameterRepresentable]) -> PaymentsParameterRepresentable? {
    
    return nil
}

private func visibleReducer(operation: Payments.Operation) async throws -> [Payments.Parameter.ID]? {
    
    return nil
}

//MARK: - Convenience Inits

private extension TransferAnywayResponseData {
    
    convenience init(parameters: [ParameterData], needSum: Bool, finalStep: Bool) {
        
        self.init(amount: nil, creditAmount: nil, currencyAmount: nil, currencyPayee: nil, currencyPayer: nil, currencyRate: nil, debitAmount: nil, fee: nil, needMake: nil, needOTP: nil, payeeName: nil, documentStatus: .inProgress, paymentOperationDetailId: 1, additionalList: [], finalStep: finalStep, infoMessage: nil, needSum: needSum, printFormType: nil, parameterListForNextStep: parameters, scenario: .ok)
    }
}

private extension ParameterData {
    
    init(id: String, value: String?) {
        
        self.init(content: value, dataType: nil, id: id, isPrint: nil, isRequired: nil, mask: nil, maxLength: nil, minLength: nil, order: nil, rawLength: 0, readOnly: nil, regExp: nil, subTitle: nil, title: "", type: "", inputFieldType: .unknown, dataDictionary: nil, dataDictionaryРarent: nil, group: nil, subGroup: nil, inputMask: nil, phoneBook: nil, svgImage: nil, viewType: .constant)
    }
}
