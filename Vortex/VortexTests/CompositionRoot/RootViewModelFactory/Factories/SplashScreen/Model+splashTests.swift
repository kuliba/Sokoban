//
//  Model+splashTests.swift
//  VortexTests
//
//  Created by Igor Malyarov on 14.03.2025.
//

@testable import Vortex
import XCTest

final class Model_splashTests: XCTestCase {
    
    // MARK: - Pin
    
    func test_pinOrSensorAuthOK_shouldNotEmit_onNoAction() {
        
        let model: Model = .mockWithEmptyExcept()
        let spy = ValueSpy(model.pinOrSensorAuthOK)
        
        XCTAssertEqual(spy.values.count, 0)
    }
    
    func test_pinOrSensorAuthOK_shouldNotEmit_onFailure() {
        
        let model: Model = .mockWithEmptyExcept()
        let spy = ValueSpy(model.pinOrSensorAuthOK)
        
        model.action.send(ModelAction.Auth.Pincode.Check.Response.failure(message: anyMessage()))
        
        XCTAssertEqual(spy.values.count, 0)
    }
    
    func test_pinOrSensorAuthOK_shouldNotEmit_onIncorrectPin() {
        
        let model: Model = .mockWithEmptyExcept()
        let spy = ValueSpy(model.pinOrSensorAuthOK)
        
        model.action.send(ModelAction.Auth.Pincode.Check.Response.incorrect(remain: 0))
        
        XCTAssertEqual(spy.values.count, 0)
    }
    
    func test_pinOrSensorAuthOK_shouldNotEmit_onRestricted() {
        
        let model: Model = .mockWithEmptyExcept()
        let spy = ValueSpy(model.pinOrSensorAuthOK)
        
        model.action.send(ModelAction.Auth.Pincode.Check.Response.restricted)
        
        XCTAssertEqual(spy.values.count, 0)
    }
    
    func test_pinOrSensorAuthOK_shouldEmit_onCorrectPin() {
        
        let model: Model = .mockWithEmptyExcept()
        let spy = ValueSpy(model.pinOrSensorAuthOK)
        
        model.action.send(ModelAction.Auth.Pincode.Check.Response.correct)
        
        XCTAssertEqual(spy.values.count, 1)
    }
    
    // MARK: - Sensor
    
    func test_pinOrSensorAuthOK_shouldNotEmit_onSensorFailure() {
        
        let model: Model = .mockWithEmptyExcept()
        let spy = ValueSpy(model.pinOrSensorAuthOK)
        
        model.action.send(ModelAction.Auth.Sensor.Evaluate.Response.failure(message: anyMessage()))
        
        XCTAssertEqual(spy.values.count, 0)
    }
    
    func test_pinOrSensorAuthOK_shouldEmit_onFaceIDSuccess() {
        
        let model: Model = .mockWithEmptyExcept()
        let spy = ValueSpy(model.pinOrSensorAuthOK)
        
        model.action.send(ModelAction.Auth.Sensor.Evaluate.Response.success(.face))
        
        XCTAssertEqual(spy.values.count, 1)
    }
    
    func test_pinOrSensorAuthOK_shouldEmit_onTouchIDSuccess() {
        
        let model: Model = .mockWithEmptyExcept()
        let spy = ValueSpy(model.pinOrSensorAuthOK)
        
        model.action.send(ModelAction.Auth.Sensor.Evaluate.Response.success(.touch))
        
        XCTAssertEqual(spy.values.count, 1)
    }
    
    // MARK: - Start
    
    func test_hideCoverStartSplash_shouldNotEmit_onRegisterRequired() {
        
        let model: Model = .mockWithEmptyExcept()
        let spy = ValueSpy(model.hideCoverStartSplash)
        
        model.auth.send(.registerRequired)
        
        XCTAssertEqual(spy.values.count, 0)
    }
    
    func test_hideCoverStartSplash_shouldNotEmit_onSignInRequired() {
        
        let model: Model = .mockWithEmptyExcept()
        let spy = ValueSpy(model.hideCoverStartSplash)
        
        model.auth.send(.signInRequired)
        
        XCTAssertEqual(spy.values.count, 0)
    }
    
    func test_hideCoverStartSplash_shouldNotEmit_onUnlockRequired() {
        
        let model: Model = .mockWithEmptyExcept()
        let spy = ValueSpy(model.hideCoverStartSplash)
        
        model.auth.send(.unlockRequired)
        
        XCTAssertEqual(spy.values.count, 0)
    }
    
    func test_hideCoverStartSplash_shouldNotEmit_onUnlockRequiredManual() {
        
        let model: Model = .mockWithEmptyExcept()
        let spy = ValueSpy(model.hideCoverStartSplash)
        
        model.auth.send(.unlockRequiredManual)
        
        XCTAssertEqual(spy.values.count, 0)
    }
    
    func test_hideCoverStartSplash_shouldEmit_onAuthorized() {
        
        let model: Model = .mockWithEmptyExcept()
        let spy = ValueSpy(model.hideCoverStartSplash)
        
        model.auth.send(.authorized)
        
        XCTAssertEqual(spy.values.count, 1)
    }
}
