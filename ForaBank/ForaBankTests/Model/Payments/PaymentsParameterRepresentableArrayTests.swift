//
//  PaymentsParameterRepresentableArrayTests.swift
//  VortexTests
//
//  Created by Max Gribov on 05.06.2023.
//

import XCTest
@testable import ForaBank

final class PaymentsParameterRepresentableArrayTests: XCTestCase {

    func test_init_empty() {
        
        let sut = makeSUT()
        
        XCTAssertTrue(sut.isEmpty)
    }
    
    func test_initWitParameters_parametersList() {
        
        let sut = makeSUT(
            [Payments.ParameterMock(id: "one", value: nil),
             Payments.ParameterMock(id: "two", value: "123")])
        
        XCTAssertEqual(sut.map(\.id), ["one", "two"])
        XCTAssertEqual(sut.map(\.value), [nil, "123"])
    }
}

//MARK: - parameter(forId:as:)

extension PaymentsParameterRepresentableArrayTests {
    
    func test_parameterForId_correct() throws {
        
        let sut = makeSUT(
            [Payments.ParameterMock(id: "one", value: "123")])
        
        let result = try sut.parameter(forId: "one")
        
        XCTAssertEqual(result.id, "one")
        XCTAssertEqual(result.value, "123")
    }
    
    func test_parameterForId_throwsErrorForMissingParameterWithId() throws {
        
        let sut = makeSUT(
            [Payments.ParameterMock(id: "one", value: "123")])
        
        XCTAssertThrowsError(try sut.parameter(forId: "wrong_id"))
    }
}


//MARK: - parameter(forIdentifier:)

extension PaymentsParameterRepresentableArrayTests {
    
    func test_parameterForIdentifier_correct() throws {
        
        let identifier: Payments.Parameter.Identifier = .amount
        let sut = makeSUT(
            [Payments.ParameterMock(id: identifier.rawValue, value: "123")])
        
        let result = try sut.parameter(forIdentifier: identifier)
        
        XCTAssertEqual(result.id, identifier.rawValue)
        XCTAssertEqual(result.value, "123")
    }
    
    func test_parameterForIdentifier_throwsErrorForMissingParameterWithId() throws {
        
        let identifier: Payments.Parameter.Identifier = .amount
        let sut = makeSUT(
            [Payments.ParameterMock(id: identifier.rawValue, value: "123")])
        
        XCTAssertThrowsError(try sut.parameter(forIdentifier: .code))
    }
}

//MARK: - parameter(forId:as:)

extension PaymentsParameterRepresentableArrayTests {
    
    func test_parameterForIdAs_correct() throws {
        
        let sut = makeSUT(
            [Payments.ParameterMock(id: "one", value: "123")])
        
        let result = try sut.parameter(forId: "one", as: Payments.ParameterMock.self)
        
        XCTAssertEqual(result.id, "one")
        XCTAssertEqual(result.value, "123")
    }
    
    func test_parameterForIdAs_throwsErrorForMissingParameterWithId() throws {
        
        let sut = makeSUT(
            [Payments.ParameterMock(id: "one", value: "123")])
        
        XCTAssertThrowsError(try sut.parameter(forId: "wrong_id", as: Payments.ParameterMock.self))
    }
    
    func test_parameterForIdAs_throwsErrorForWrongType() throws {
        
        let sut = makeSUT(
            [Payments.ParameterMock(id: "one", value: "123")])
        
        XCTAssertThrowsError(try sut.parameter(forId: "one", as: Payments.ParameterAmount.self))
    }
}

//MARK: - parameter(forIdentifier:as:)

extension PaymentsParameterRepresentableArrayTests {
    
    func test_parameterForIdentifierAs_correct() throws {
        
        let identifier: Payments.Parameter.Identifier = .amount
        let sut = makeSUT(
            [Payments.ParameterMock(id: identifier.rawValue, value: "123")])
        
        let result = try sut.parameter(forIdentifier: identifier, as: Payments.ParameterMock.self)
        
        XCTAssertEqual(result.id, identifier.rawValue)
        XCTAssertEqual(result.value, "123")
    }
    
    func test_parameterForIdentifierAs_throwsErrorForWrongType() throws {
        
        let identifier: Payments.Parameter.Identifier = .amount
        let sut = makeSUT(
            [Payments.ParameterMock(id: identifier.rawValue, value: "123")])

        XCTAssertThrowsError(try sut.parameter(forId: identifier.rawValue, as: Payments.ParameterAmount.self))
    }
    
    func test_parameterForIdentifierAs_throwsErrorForMissingParameterWithId() throws {
        
        let identifier: Payments.Parameter.Identifier = .amount
        let sut = makeSUT(
            [Payments.ParameterMock(id: identifier.rawValue, value: "123")])

        XCTAssertThrowsError(try sut.parameter(forIdentifier: .code, as: Payments.ParameterAmount.self))
    }
}

//MARK: - value(forId:)

extension PaymentsParameterRepresentableArrayTests {
    
    func test_valueForId_correct() throws {
        
        let sut = makeSUT(
            [Payments.ParameterMock(id: "one", value: "123")])
        
        let result = try sut.value(forId: "one")
        
        XCTAssertEqual(result, "123")
    }
    
    func test_valueForId_throwsErrorForMissingParameterWithId() throws {
        
        let sut = makeSUT(
            [Payments.ParameterMock(id: "one", value: "123")])
        
        XCTAssertThrowsError(try sut.value(forId: "wrong_id"))
    }
    
    func test_valueForId_throwsErrorWithNilParameterValue() throws {
        
        let sut = makeSUT(
            [Payments.ParameterMock(id: "one", value: nil)])
        
        XCTAssertThrowsError(try sut.value(forId: "one"))
    }
}

//MARK: - value(forIdentifier:)

extension PaymentsParameterRepresentableArrayTests {
    
    func test_valueForIdentifier_correct() throws {
        
        let identifier: Payments.Parameter.Identifier = .amount
        let sut = makeSUT(
            [Payments.ParameterMock(id: identifier.rawValue, value: "123")])
        
        let result = try sut.value(forIdentifier: identifier)
        
        XCTAssertEqual(result, "123")
    }
    
    func test_valueForIdentifier_throwsErrorForMissingParameterWithId() throws {
        
        let identifier: Payments.Parameter.Identifier = .amount
        let sut = makeSUT(
            [Payments.ParameterMock(id: identifier.rawValue, value: "123")])
        
        XCTAssertThrowsError(try sut.value(forIdentifier: .code))
    }
    
    func test_valueForIdentifier_throwsErrorWithNilParameterValue() throws {
        
        let identifier: Payments.Parameter.Identifier = .amount
        let sut = makeSUT(
            [Payments.ParameterMock(id: identifier.rawValue, value: nil)])
        
        XCTAssertThrowsError(try sut.value(forIdentifier: identifier))
    }
}

private extension PaymentsParameterRepresentableArrayTests {
    
    func makeSUT(_ parameters: [PaymentsParameterRepresentable] = []) -> [PaymentsParameterRepresentable] {
        
        return parameters
    }
}

