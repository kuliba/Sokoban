//
//  PaymentsParameterHelpersTests.swift
//  ForaBankTests
//
//  Created by Max Gribov on 07.09.2022.
//

import XCTest
@testable import ForaBank

class PaymentsParameterHelpersTests: XCTestCase {

    let model: Model = .emptyMock

    //MARK: - Is Transfer Restart Required
    
    func testIsTransferRestartRequired_True() throws {
  
        // given
        let parameter = Payments.ParameterMock(value: "100", processStep: 1)
        let parameterId = parameter.parameter.id
        let history: [[Payments.Parameter]] = [[.init(id: parameterId, value: "100")], [.init(id: parameterId, value: "200")]]
        
        // when
        let result = model.paymentsIsTransferRestartRequired(parameters: [parameter], history: history)
        
        // then
        XCTAssertTrue(result)
    }
    
    func testIsTransferRestartRequiered_False() throws {
        
        // given
        let parameter = Payments.ParameterMock(value: "200", processStep: 1)
        let parameterId = parameter.parameter.id
        let history: [[Payments.Parameter]] = [[.init(id: parameterId, value: "200")], [.init(id: parameterId, value: "200")]]
        
        // when
        let result = model.paymentsIsTransferRestartRequired(parameters: [parameter], history: history)
        
        // then
        XCTAssertFalse(result)
    }

    // MARK: - Transfer Process Step Minimal
    
    func testTransferProcessStepMin_Value() throws {
        
        // given
        let parameterFirst = Payments.ParameterMock(id: "first", value: "100", processStep: 1)
        let parameterSecond = Payments.ParameterMock(id: "second", value: "200", processStep: 2)
        let paramererThird = Payments.ParameterMock(id: "third", value: "300")
        let parameters = [parameterFirst, parameterSecond, paramererThird]
        
        // when
        let result = model.paymentsTransferProcessStepMin(parameters: parameters)
        
        // then
        XCTAssertEqual(result, 1)
    }
    
    func testTransferProcessStepMin_Nil() throws {
        
        // given
        let parameterFirst = Payments.ParameterMock(id: "first", value: "100")
        let parameterSecond = Payments.ParameterMock(id: "second", value: "200")
        let paramererThird = Payments.ParameterMock(id: "third", value: "300")
        let parameters = [parameterFirst, parameterSecond, paramererThird]
        
        // when
        let result = model.paymentsTransferProcessStepMin(parameters: parameters)
        
        // then
        XCTAssertNil(result)
    }
    
    //MARK: - Transfer Parameters For Step
    
    func testTransferParametersForStep_Value() throws {
        
        // given
        let parameterFirst = Payments.ParameterMock(id: "first", value: "100", processStep: 1)
        let parameterSecond = Payments.ParameterMock(id: "second", value: "200", processStep: 2)
        let paramererThird = Payments.ParameterMock(id: "third", value: "300")
        let parameters = [parameterFirst, parameterSecond, paramererThird]
        
        // when
        let result = model.paymentsTransferParametersForStep(parameters: parameters, step: 2)
        
        // then
        XCTAssertEqual(result?.count, 1)
        XCTAssertEqual(result?.first, .init(id: "second", value: "200"))
    }
    
    func testTransferParametersForStep_Nil() throws {
        
        // given
        let parameterFirst = Payments.ParameterMock(id: "first", value: "100", processStep: 1)
        let parameterSecond = Payments.ParameterMock(id: "second", value: "200", processStep: 2)
        let paramererThird = Payments.ParameterMock(id: "third", value: "300")
        let parameters = [parameterFirst, parameterSecond, paramererThird]
        
        // when
        let result = model.paymentsTransferParametersForStep(parameters: parameters, step: 3)
        
        // then
        XCTAssertNil(result)
    }
}
