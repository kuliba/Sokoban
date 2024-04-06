//
//  UpdateAnywayPaymentTests.swift
//
//
//  Created by Igor Malyarov on 04.04.2024.
//

import AnywayPaymentCore
import XCTest

final class UpdateAnywayPaymentTests: XCTestCase {
    
    // MARK: - amount
    
    func test_update_shouldNotAddAmountFieldOnNeedSumFalse() {
        
        assert(
            makeAnywayPaymentWithoutAmount(),
            on: makeAnywayPaymentUpdate(needSum: false)
        )
    }
    
    func test_update_shouldAddAmountFieldOnNeedSumTrue() {
        
        let update = makeAnywayPaymentUpdate(needSum: true)
        let updated = makeAnywayPaymentWithoutAmount().update(with: update)
        
        XCTAssert(hasAmountField(updated))
    }
    
    func test_update_shouldRemoveAmountFieldOnNeedSumFalse() {
        
        let update = makeAnywayPaymentUpdate(needSum: false)
        let updated = makeAnywayPaymentWithAmount().update(with: update)
        
        XCTAssertFalse(hasAmountField(updated))
    }
    
    // MARK: - complimentary fields
    
    func test_update_shouldAppendComplementaryFieldToEmpty() {
        
        let payment = makeAnywayPayment()
        let updateField = makeAnywayPaymentUpdateField("a", value: "aa", title: "aaa")
        let update = makeAnywayPaymentUpdate(fields: [updateField])
        let updated = makeAnywayPaymentField(.string("a"), value: "aa", title: "aaa")
        
        XCTAssertNoDiff(payment.elements, [])
        assert(payment, on: update) {
            
            $0.elements = [AnywayPayment.Element.field(updated)]
        }
    }
    
    func test_update_shouldAppendComplementaryFieldsToEmpty() {
        
        let payment = makeAnywayPayment()
        let update = makeAnywayPaymentUpdate(
            fields: [
                makeAnywayPaymentUpdateField("a", value: "aa", title: "aaa"),
                makeAnywayPaymentUpdateField("b", value: "bb", title: "bbb"),
                makeAnywayPaymentUpdateField("c", value: "cc", title: "ccc")
            ]
        )
        
        XCTAssertNoDiff(payment.elements, [])
        assert(payment, on: update) {
            
            $0.elements = [
                .init(id: .string("a"), value: "aa", title: "aaa"),
                .init(id: .string("b"), value: "bb", title: "bbb"),
                .init(id: .string("c"), value: "cc", title: "ccc"),
            ].map(AnywayPayment.Element.field)
        }
    }
    
    func test_update_shouldAppendComplimentaryStringIDFieldToNonEmpty() {
        
        let field = makeAnywayPaymentFieldWithStringID()
        let payment = makeAnywayPayment(fields: [field])
        let (fieldUpdate, updatedField) = makeAnywayPaymentAndUpdateFields()
        let update = makeAnywayPaymentUpdate(fields: [fieldUpdate])
        
        assert(payment, on: update) {
            
            let fields = [field].appending(updatedField)
            $0.elements = fields.map(AnywayPayment.Element.field)
        }
    }
    
    func test_update_shouldAppendComplimentaryStringIDFieldsToNonEmpty() {
        
        let field = makeAnywayPaymentFieldWithStringID()
        let payment = makeAnywayPayment(fields: [field])
        let (fieldUpdate1, updatedField1) = makeAnywayPaymentAndUpdateFields()
        let (fieldUpdate2, updatedField2) = makeAnywayPaymentAndUpdateFields()
        let update = makeAnywayPaymentUpdate(fields: [
            fieldUpdate1, fieldUpdate2
        ])
        
        assert(payment, on: update) {
            
            let fields = [field, updatedField1, updatedField2]
            $0.elements = fields.map(AnywayPayment.Element.field)
        }
    }
    
    // MARK: - fraud
    
    func test_update_shouldNotChangeFraudSuspectedOnFraudSuspectedFalse() {
        
        assert(
            makeAnywayPaymentWithoutFraudSuspected(),
            on: makeAnywayPaymentUpdate(isFraudSuspected: false)
        )
    }
    
    func test_update_shouldSetFraudSuspectedOnFraudSuspectedTrue() {
        
        let update = makeAnywayPaymentUpdate(isFraudSuspected: true)
        let updated = makeAnywayPaymentWithoutFraudSuspected().update(with: update)
        
        XCTAssert(isFraudSuspected(updated))
    }
    
    func test_update_shouldRemoveFraudSuspectedFieldOnFraudSuspectedFalse() {
        
        let update = makeAnywayPaymentUpdate(isFraudSuspected: false)
        let updated = makeAnywayPaymentWithFraudSuspected().update(with: update)
        
        XCTAssertFalse(isFraudSuspected(updated))
    }
    
    // MARK: - isFinalStep
    
    func test_update_shouldNotChangeIsFinalStepFlagOnIsFinalStepFalse() {
        
        assert(
            makeNonFinalStepAnywayPayment(),
            on: makeAnywayPaymentUpdate(isFinalStep: false)
        )
    }
    
    func test_update_shouldSetIsFinalStepFlagOnIsFinalStepTrue() {
        
        let update = makeAnywayPaymentUpdate(isFinalStep: true)
        let updated = makeNonFinalStepAnywayPayment().update(with: update)
        
        XCTAssert(isFinalStep(updated))
    }
    
    func test_update_shouldSetIsFinalStepFlagOnIsFinalStepFalse() {
        
        let update = makeAnywayPaymentUpdate(isFinalStep: false)
        let updated = makeFinalStepAnywayPayment().update(with: update)
        
        XCTAssertFalse(isFinalStep(updated))
    }
    
    // MARK: - infoMessage
    
    func test_update_shouldNotChangeStatusOnNilInfoMessage() {
        
        assert(
            makeAnywayPayment(),
            on: makeAnywayPaymentUpdate(infoMessage: nil)
        )
    }
    
    func test_update_shouldChangeStatusOnNonNilInfoMessage() {
        
        let message = anyMessage()
        
        assert(
            makeAnywayPayment(),
            on: makeAnywayPaymentUpdate(infoMessage: message)
        ) {
            $0.status = .infoMessage(message)
        }
    }
    
    // MARK: - non-complimentary (primary) fields
    
    func test_update_shouldNotChangeStringIDFieldWithSameValueInNonComplementaryFields() {
        
        let (id, value, title) = ("abc123", "aaa", "bb")
        let field = makeAnywayPaymentFieldWithStringID(id, value: value, title: title)
        let payment = makeAnywayPayment(fields: [field])
        let updateField = makeAnywayPaymentUpdateField(id, value: value, title: title)
        let update = makeAnywayPaymentUpdate(fields: [updateField])
        
        assert(payment, on: update)
    }
    
    func test_update_shouldChangeStringIDFieldWithDifferentValueInNonComplementaryFields() {
        
        let id = anyMessage()
        let field = makeAnywayPaymentFieldWithStringID(id)
        let payment = makeAnywayPayment(fields: [field])
        let (fieldUpdate, updatedField) = makeAnywayPaymentAndUpdateFields(id, value: "aa", title: "bbb")
        let update = makeAnywayPaymentUpdate(fields: [fieldUpdate])
        
        assert(payment, on: update) {
            
            $0.elements = [.field(updatedField)]
        }
    }
    
    func test_update_shouldUpdateExistingFieldOnUpdateWithDifferentValue() {
        
        let field = makeAnywayPaymentFieldWithStringID("e1")
        let payment = makeAnywayPayment(elements: [.field(field)])
        
        let newValue = anyMessage()
        let (fieldUpdate, updatedField) = makeAnywayPaymentAndUpdateFields("e1", value: newValue)
        let (fieldUpdate2, updatedField2) = makeAnywayPaymentAndUpdateFields()
        
        let update = makeAnywayPaymentUpdate(
            fields: [fieldUpdate, fieldUpdate2]
        )
        
        assert(payment, on: update) {
            
            $0.elements = [.field(updatedField), .field(updatedField2)]
        }
    }
    
    // MARK: - OTP
    
    func test_update_shouldNotAddOTPFieldOnNeedOTPFalse() {
        
        assert(
            makeAnywayPaymentWithoutOTP(),
            on: makeAnywayPaymentUpdate(needOTP: false)
        )
    }
    
    func test_update_shouldAddOTPFieldOnNeedOTPTrue() {
        
        let update = makeAnywayPaymentUpdate(needOTP: true)
        let updated = makeAnywayPaymentWithoutOTP().update(with: update)
        
        XCTAssert(hasOTPField(updated))
    }
    
    func test_update_shouldRemoveOTPFieldOnNeedOTPFalse() {
        
        let update = makeAnywayPaymentUpdate(needOTP: false)
        let updated = makeAnywayPaymentWithOTP().update(with: update)
        
        XCTAssertFalse(hasOTPField(updated))
    }
    
    func test_update_shouldAppendOTPFieldAfterEmptyComplementaryFieldsOnNeedOTPTrue() {
        
        let payment = makeAnywayPaymentWithoutOTP()
        let update = makeAnywayPaymentUpdate(
            fields: [],
            needOTP: true
        )
        
        let updated = payment.update(with: update)
        
        assertOTP(in: updated, precedes: [])
    }
    
    func test_update_shouldAppendOTPFieldAfterComplementaryFieldsOnNeedOTPTrue() {
        
        let payment = makeAnywayPaymentWithoutOTP()
        let (fieldUpdate1, updatedField1) = makeAnywayPaymentAndUpdateFields()
        let (fieldUpdate2, updatedField2) = makeAnywayPaymentAndUpdateFields()
        
        let update = makeAnywayPaymentUpdate(
            fields: [fieldUpdate1, fieldUpdate2],
            needOTP: true
        )
        
        let updated = payment.update(with: update)
        
        assertOTP(in: updated, precedes: [updatedField1, updatedField2])
    }
    
    // MARK: - parameters
    
    func test_update_shouldAppendParameterToEmpty() {
        
        let payment = makeAnywayPayment(parameters: [])
        let (parameterUpdate, updatedParameter) = makeAnywayPaymentAndUpdateParameters()
        let update = makeAnywayPaymentUpdate(parameters: [parameterUpdate])
        
        assert(payment, on: update) {
            
            $0.elements = [.parameter(updatedParameter)]
        }
    }
    
    func test_update_shouldAppendParameterToOneField() {
        
        let field = makeAnywayPaymentField()
        let payment = makeAnywayPayment(fields: [field])
        let (parameterUpdate, updatedParameter) = makeAnywayPaymentAndUpdateParameters()
        let update = makeAnywayPaymentUpdate(parameters: [parameterUpdate])
        
        assert(payment, on: update) {
            
            $0.elements = [.field(field), .parameter(updatedParameter)]
        }
    }
    
    func test_update_shouldAppendParameterToTwoFields() {
        
        let field1 = makeAnywayPaymentField()
        let field2 = makeAnywayPaymentField()
        let payment = makeAnywayPayment(fields: [field1, field2])
        let (parameterUpdate, updatedParameter) = makeAnywayPaymentAndUpdateParameters()
        let update = makeAnywayPaymentUpdate(parameters: [parameterUpdate])
        
        assert(payment, on: update) {
            
            $0.elements = [.field(field1), .field(field2), .parameter(updatedParameter)]
        }
    }
    
    func test_update_shouldAppendParameterToFieldAndParameter() {
        
        let field = makeAnywayPaymentField()
        let parameter = makeAnywayPaymentParameter()
        let payment = makeAnywayPayment(
            elements: [.field(field), .parameter(parameter)]
        )
        let (parameterUpdate, updatedParameter) = makeAnywayPaymentAndUpdateParameters()
        let update = makeAnywayPaymentUpdate(parameters: [parameterUpdate])
        
        assert(payment, on: update) {
            
            $0.elements = [.field(field), .parameter(parameter), .parameter(updatedParameter)]
        }
    }
    
    func test_update_shouldAppendParameterToParameterAndField() {
        
        let parameter = makeAnywayPaymentParameter()
        let field = makeAnywayPaymentField()
        let payment = makeAnywayPayment(
            elements: [.parameter(parameter), .field(field)]
        )
        let (parameterUpdate, updatedParameter) = makeAnywayPaymentAndUpdateParameters()
        let update = makeAnywayPaymentUpdate(parameters: [parameterUpdate])
        
        assert(payment, on: update) {
            
            $0.elements = [.parameter(parameter), .field(field), .parameter(updatedParameter)]
        }
    }
    
    func test_update_shouldAppendParameterToOneParameter() {
        
        let parameter = makeAnywayPaymentParameter()
        let payment = makeAnywayPayment(parameters: [parameter])
        let (parameterUpdate, updatedParameter) = makeAnywayPaymentAndUpdateParameters()
        let update = makeAnywayPaymentUpdate(parameters: [parameterUpdate])
        
        assert(payment, on: update) {
            
            $0.elements = [.parameter(parameter), .parameter(updatedParameter)]
        }
    }
    
    func test_update_shouldAppendParameterToTwoParameters() {
        
        let parameter1 = makeAnywayPaymentParameter()
        let parameter2 = makeAnywayPaymentParameter()
        let payment = makeAnywayPayment(parameters: [parameter1, parameter2])
        let (parameterUpdate, updatedParameter) = makeAnywayPaymentAndUpdateParameters()
        let update = makeAnywayPaymentUpdate(parameters: [parameterUpdate])
        
        assert(payment, on: update) {
            
            $0.elements = [parameter1, parameter2, updatedParameter].map(AnywayPayment.Element.parameter)
        }
    }
    
    func test_update_shouldAppendTwoParametersToEmpty() {
        
        let payment = makeAnywayPayment(parameters: [])
        let (parameterUpdate1, updatedParameter1) = makeAnywayPaymentAndUpdateParameters()
        let (parameterUpdate2, updatedParameter2) = makeAnywayPaymentAndUpdateParameters()
        let update = makeAnywayPaymentUpdate(
            parameters: [parameterUpdate1, parameterUpdate2]
        )
        
        assert(payment, on: update) {
            
            $0.elements = [updatedParameter1, updatedParameter2].map(AnywayPayment.Element.parameter)
        }
    }
    
    func test_update_shouldAppendTwoParametersToOneField() {
        
        let field = makeAnywayPaymentField()
        let payment = makeAnywayPayment(fields: [field])
        let (parameterUpdate1, updatedParameter1) = makeAnywayPaymentAndUpdateParameters()
        let (parameterUpdate2, updatedParameter2) = makeAnywayPaymentAndUpdateParameters()
        let update = makeAnywayPaymentUpdate(
            parameters: [parameterUpdate1, parameterUpdate2]
        )
        
        assert(payment, on: update) {
            
            let appending = [updatedParameter1, updatedParameter2].map(AnywayPayment.Element.parameter)
            $0.elements = [.field(field)] + appending
        }
    }
    
    func test_update_shouldAppendTwoParametersToTwoFields() {
        
        let field1 = makeAnywayPaymentField()
        let field2 = makeAnywayPaymentField()
        let payment = makeAnywayPayment(fields: [field1, field2])
        let (parameterUpdate1, updatedParameter1) = makeAnywayPaymentAndUpdateParameters()
        let (parameterUpdate2, updatedParameter2) = makeAnywayPaymentAndUpdateParameters()
        let update = makeAnywayPaymentUpdate(
            parameters: [parameterUpdate1, parameterUpdate2]
        )
        
        assert(payment, on: update) {
            
            let appending = [updatedParameter1, updatedParameter2].map(AnywayPayment.Element.parameter)
            $0.elements = [.field(field1), .field(field2)] + appending
        }
    }
    
    func test_update_shouldAppendTwoParametersToFieldAndParameter() {
        
        let field = makeAnywayPaymentField()
        let parameter = makeAnywayPaymentParameter()
        let payment = makeAnywayPayment(
            elements: [.field(field), .parameter(parameter)]
        )
        let (parameterUpdate1, updatedParameter1) = makeAnywayPaymentAndUpdateParameters()
        let (parameterUpdate2, updatedParameter2) = makeAnywayPaymentAndUpdateParameters()
        let update = makeAnywayPaymentUpdate(
            parameters: [parameterUpdate1, parameterUpdate2]
        )
        
        assert(payment, on: update) {
            
            let appending = [updatedParameter1, updatedParameter2].map(AnywayPayment.Element.parameter)
            $0.elements = [.field(field), .parameter(parameter)] + appending
        }
    }
    
    func test_update_shouldAppendTwoParametersToParameterAndField() {
        
        let parameter = makeAnywayPaymentParameter()
        let field = makeAnywayPaymentField()
        let payment = makeAnywayPayment(
            elements: [.parameter(parameter), .field(field)]
        )
        let (parameterUpdate1, updatedParameter1) = makeAnywayPaymentAndUpdateParameters()
        let (parameterUpdate2, updatedParameter2) = makeAnywayPaymentAndUpdateParameters()
        let update = makeAnywayPaymentUpdate(
            parameters: [parameterUpdate1, parameterUpdate2]
        )
        
        assert(payment, on: update) {
            
            let appending = [updatedParameter1, updatedParameter2].map(AnywayPayment.Element.parameter)
            $0.elements = [.parameter(parameter), .field(field)] + appending
        }
    }
    
    func test_update_shouldAppendTwoParametersToOneParameter() {
        
        let parameter = makeAnywayPaymentParameter()
        let payment = makeAnywayPayment(parameters: [parameter])
        let (parameterUpdate1, updatedParameter1) = makeAnywayPaymentAndUpdateParameters()
        let (parameterUpdate2, updatedParameter2) = makeAnywayPaymentAndUpdateParameters()
        let update = makeAnywayPaymentUpdate(
            parameters: [parameterUpdate1, parameterUpdate2]
        )
        
        assert(payment, on: update) {
            
            $0.elements = [parameter, updatedParameter1, updatedParameter2]
                .map(AnywayPayment.Element.parameter)
        }
    }
    
    func test_update_shouldAppendTwoParametersToTwoParameters() {
        
        let parameter1 = makeAnywayPaymentParameter()
        let parameter2 = makeAnywayPaymentParameter()
        let payment = makeAnywayPayment(parameters: [parameter1, parameter2])
        let (parameterUpdate1, updatedParameter1) = makeAnywayPaymentAndUpdateParameters()
        let (parameterUpdate2, updatedParameter2) = makeAnywayPaymentAndUpdateParameters()
        let update = makeAnywayPaymentUpdate(
            parameters: [parameterUpdate1, parameterUpdate2]
        )
        
        assert(payment, on: update) {
            
            $0.elements = [parameter1, parameter2, updatedParameter1, updatedParameter2]
                .map(AnywayPayment.Element.parameter)
        }
    }
    
    func test_update_shouldAppendFieldAndParameterToEmptyOnUpdateWithParameterAndComplimentoryField() {
        
        let payment = makeAnywayPayment(elements: [])
        let (fieldUpdate, updatedField) = makeAnywayPaymentAndUpdateFields()
        let (parameterUpdate, updatedParameter) = makeAnywayPaymentAndUpdateParameters()
        let update = makeAnywayPaymentUpdate(
            fields: [fieldUpdate],
            parameters: [parameterUpdate]
        )
        
        assert(payment, on: update) {
            
            $0.elements = [.field(updatedField), .parameter(updatedParameter)]
        }
    }
    
    func test_update_shouldAppendElementsToEmptyOnUpdateWithParametersAndComplimentoryFields() {
        
        let payment = makeAnywayPayment(elements: [])
        let (fieldUpdate1, updatedField1) = makeAnywayPaymentAndUpdateFields()
        let (fieldUpdate2, updatedField2) = makeAnywayPaymentAndUpdateFields()
        let (parameterUpdate1, updatedParameter1) = makeAnywayPaymentAndUpdateParameters()
        let (parameterUpdate2, updatedParameter2) = makeAnywayPaymentAndUpdateParameters()
        let update = makeAnywayPaymentUpdate(
            fields: [fieldUpdate1, fieldUpdate2],
            parameters: [parameterUpdate1, parameterUpdate2]
        )
        
        assert(payment, on: update) {
            
            let complimentaryFields = [updatedField1, updatedField2]
            let parameters = [updatedParameter1, updatedParameter2]
            $0.elements = complimentaryFields.map(AnywayPayment.Element.field)
            + parameters.map(AnywayPayment.Element.parameter)
        }
    }
    
    func test_update_shouldAppendFieldAndParameterToNonEmptyOnUpdateWithParameterAndComplimentoryField() {
        
        let field = makeAnywayPaymentField()
        let parameter = makeAnywayPaymentParameter()
        let payment = makeAnywayPayment(elements: [.field(field), .parameter(parameter)])
        let (fieldUpdate, updatedField) = makeAnywayPaymentAndUpdateFields()
        let (parameterUpdate, updatedParameter) = makeAnywayPaymentAndUpdateParameters()
        let update = makeAnywayPaymentUpdate(
            fields: [fieldUpdate],
            parameters: [parameterUpdate]
        )
        
        assert(payment, on: update) {
            
            $0.elements = [.field(field), .parameter(parameter), .field(updatedField), .parameter(updatedParameter)]
        }
    }
    
    func test_update_shouldAppendElementsToNonEmptyOnUpdateWithParametersAndComplimentoryFields() {
        
        let field = makeAnywayPaymentField()
        let parameter = makeAnywayPaymentParameter()
        let payment = makeAnywayPayment(elements: [.field(field), .parameter(parameter)])
        
        let (fieldUpdate1, updatedField1) = makeAnywayPaymentAndUpdateFields()
        let (fieldUpdate2, updatedField2) = makeAnywayPaymentAndUpdateFields()
        let (parameterUpdate1, updatedParameter1) = makeAnywayPaymentAndUpdateParameters()
        let (parameterUpdate2, updatedParameter2) = makeAnywayPaymentAndUpdateParameters()
        let update = makeAnywayPaymentUpdate(
            fields: [fieldUpdate1, fieldUpdate2],
            parameters: [parameterUpdate1, parameterUpdate2]
        )
        
        assert(payment, on: update) {
            
            let complimentaryFields = [updatedField1, updatedField2]
            let parameters = [updatedParameter1, updatedParameter2]
            $0.elements = [.field(field), .parameter(parameter)]
            + complimentaryFields.map(AnywayPayment.Element.field)
            + parameters.map(AnywayPayment.Element.parameter)
        }
    }
    
    func test_update_shouldUpdateExistingParameterOnUpdateWithDifferentValue() {
        
        let id = anyMessage()
        let parameter = makeAnywayPaymentParameterWithID(id)
        let payment = makeAnywayPayment(elements: [.parameter(parameter)])
        
        let newValue = anyMessage()
        let fieldUpdate = makeAnywayPaymentUpdateField(id, value: newValue)
        let update = makeAnywayPaymentUpdate(fields: [fieldUpdate])
        
        assert(payment, on: update) {
            
            $0.elements = [.parameter(parameter.updating(value: newValue))]
        }
    }

    func test_update_shouldUpdateExistingParameterOnMatchingIDFieldUpdateWithDifferentValue() {
        
        let matchingID = anyMessage()
        let parameter = makeAnywayPaymentParameterWithID(matchingID)
        let payment = makeAnywayPayment(elements: [.parameter(parameter)])
        
        let newValue = anyMessage()
        let fieldUpdate = makeAnywayPaymentUpdateField(matchingID, value: newValue)
        let (parameterUpdate2, updatedParameter2) = makeAnywayPaymentAndUpdateParameters()
        let update = makeAnywayPaymentUpdate(
            fields: [fieldUpdate],
            parameters: [parameterUpdate2]
        )
        
        assert(payment, on: update) {
            
            $0.elements = [
                .parameter(parameter.updating(value: newValue)),
                .parameter(updatedParameter2)
            ]
        }
    }

    // MARK: - Helpers Tests
    
    func test_makeAnywayPaymentAndUpdateParameters() {
        
        let (update, parameter) = makeAnywayPaymentAndUpdateParameters(
            value: nil,
            dataType: .string,
            type: .select,
            viewType: .input
        )
        
        XCTAssertNil(update.field.content)
        XCTAssertNil(parameter.field.value)
        
        XCTAssertNoDiff(update.uiAttributes.dataType, .string)
        XCTAssertNoDiff(parameter.uiAttributes.dataType, .string)
        
        XCTAssertNoDiff(update.uiAttributes.type, .select)
        XCTAssertNoDiff(parameter.uiAttributes.type, .select)
        
        XCTAssertNoDiff(update.uiAttributes.viewType, .input)
        XCTAssertNoDiff(parameter.uiAttributes.viewType, .input)
    }
    
    func test_makeAnywayPaymentAndUpdateParameters_2() {
        
        let value = anyMessage()
        let (update, parameter) = makeAnywayPaymentAndUpdateParameters(
            value: value,
            dataType: .pairs([.init(key: "a", value: "1")]),
            group: nil,
            isPrint: true,
            type: .input,
            viewType: .constant
        )
        
        XCTAssertNoDiff(update.field.content, value)
        XCTAssertNoDiff(parameter.field.value, value)
        
        XCTAssertNoDiff(update.uiAttributes.dataType, .pairs([.init(key: "a", value: "1")]))
        XCTAssertNoDiff(parameter.uiAttributes.dataType, .pairs([.init(key: "a", value: "1")]))
        
        XCTAssertNil(update.uiAttributes.group)
        XCTAssertNil(parameter.uiAttributes.group)
        
        XCTAssertTrue(update.uiAttributes.isPrint)
        XCTAssertTrue(parameter.uiAttributes.isPrint)
        
        XCTAssertNoDiff(update.uiAttributes.type, .input)
        XCTAssertNoDiff(parameter.uiAttributes.type, .input)
        
        XCTAssertNoDiff(update.uiAttributes.viewType, .constant)
        XCTAssertNoDiff(parameter.uiAttributes.viewType, .constant)
    }
    
    func test_makeAnywayPaymentAndUpdateParameters_3() {
        
        let (update, parameter) = makeAnywayPaymentAndUpdateParameters(
            dataType: .pairs([.init(key: "a", value: "1"), .init(key: "b", value: "c")]),
            group: "group",
            isPrint: false,
            type: .maskList,
            viewType: .output
        )
        
        XCTAssertNoDiff(update.uiAttributes.dataType, .pairs([.init(key: "a", value: "1"), .init(key: "b", value: "c")]))
        XCTAssertNoDiff(parameter.uiAttributes.dataType, .pairs([.init(key: "a", value: "1"), .init(key: "b", value: "c")]))
        
        XCTAssertNoDiff(update.uiAttributes.type, .maskList)
        XCTAssertNoDiff(parameter.uiAttributes.type, .maskList)
        
        XCTAssertNoDiff(update.uiAttributes.group, "group")
        XCTAssertNoDiff(parameter.uiAttributes.group, "group")
        
        XCTAssertFalse(update.uiAttributes.isPrint)
        XCTAssertFalse(parameter.uiAttributes.isPrint)

        XCTAssertNoDiff(update.uiAttributes.viewType, .output)
        XCTAssertNoDiff(parameter.uiAttributes.viewType, .output)
    }
    
    // MARK: - Helpers
    
    private typealias UpdateToExpected<T> = (_ value: inout T) -> Void
    
    private func assert(
        _ payment: AnywayPayment,
        on update: AnywayPaymentUpdate,
        updateToExpected: UpdateToExpected<AnywayPayment>? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        var expected = payment
        updateToExpected?(&expected)
        
        let received = payment.update(with: update)
        
        XCTAssertNoDiff(
            received, expected,
            "\nExpected \(expected), but got \(received) instead.",
            file: file, line: line
        )
    }
}

private func assertOTP(
    in payment: AnywayPayment,
    precedes fields: [AnywayPayment.Element.Field],
    file: StaticString = #file,
    line: UInt = #line
) {
    XCTAssert(
        hasOTPField(payment),
        "Expected OTP field in payment fields.",
        file: file, line: line
    )
    
#warning("this check is for fields only - is it ok or it needs to check all element cases?")
    XCTAssert(
        payment.paymentFields.isElementAfterAll(.otp, inGroup: fields),
        "Expected OTP field after complimentary fields.",
        file: file, line: line
    )
}

private func hasAmountField(
    _ payment: AnywayPayment
) -> Bool {
    
    payment.hasAmount
}

private func hasOTPField(
    _ payment: AnywayPayment
) -> Bool {
    
    payment.paymentFields.map(\.id).contains(.otp)
}

private extension AnywayPayment {
    
    var paymentFields: [Element.Field] {
        
        elements.compactMap {
            
            guard case let .field(field) = $0 else { return nil }
            return field
        }
    }
}

private func isFinalStep(
    _ payment: AnywayPayment
) -> Bool {
    
    payment.isFinalStep
}

private func isFraudSuspected(
    _ payment: AnywayPayment
) -> Bool {
    
    payment.isFraudSuspected
}

private func makeAnywayPayment(
    fields: [AnywayPayment.Element.Field],
    isFinalStep: Bool = false,
    isFraudSuspected: Bool = false,
    hasAmount: Bool = false
) -> AnywayPayment {
    
    makeAnywayPayment(
        elements: fields.map(AnywayPayment.Element.field),
        hasAmount: hasAmount,
        isFinalStep: isFinalStep,
        isFraudSuspected: isFraudSuspected
    )
}

private func makeAnywayPayment(
    parameters: [AnywayPayment.Element.Parameter] = [],
    isFinalStep: Bool = false,
    isFraudSuspected: Bool = false,
    hasAmount: Bool = false
) -> AnywayPayment {
    
    makeAnywayPayment(
        elements: parameters.map(AnywayPayment.Element.parameter),
        hasAmount: hasAmount,
        isFinalStep: isFinalStep,
        isFraudSuspected: isFraudSuspected
    )
}

private func makeAnywayPayment(
    elements: [AnywayPayment.Element],
    hasAmount: Bool = false,
    isFinalStep: Bool = false,
    isFraudSuspected: Bool = false
) -> AnywayPayment {
    
    .init(
        elements: elements,
        hasAmount: hasAmount,
        isFinalStep: isFinalStep,
        isFraudSuspected: isFraudSuspected
    )
}

private func makeAnywayPaymentWithAmount(
    file: StaticString = #file,
    line: UInt = #line
) -> AnywayPayment {
    
    let payment = makeAnywayPayment(hasAmount: true)
    XCTAssert(hasAmountField(payment), "Expected amount field.", file: file, line: line)
    return payment
}

private func makeAnywayPaymentWithoutAmount(
    file: StaticString = #file,
    line: UInt = #line
) -> AnywayPayment {
    
    let payment = makeAnywayPayment()
    XCTAssertFalse(hasAmountField(payment), "Expected no amount field.", file: file, line: line)
    return payment
}

private func makeAnywayPaymentWithFraudSuspected(
    file: StaticString = #file,
    line: UInt = #line
) -> AnywayPayment {
    
    let payment = makeAnywayPayment(isFraudSuspected: true)
    XCTAssert(isFraudSuspected(payment), "Expected fraud suspected payment.", file: file, line: line)
    return payment
}

private func makeAnywayPaymentWithoutFraudSuspected(
    file: StaticString = #file,
    line: UInt = #line
) -> AnywayPayment {
    
    let payment = makeAnywayPayment()
    XCTAssertFalse(isFraudSuspected(payment), "Expected pyament without fraud suspected.", file: file, line: line)
    return payment
}

private func makeAnywayPaymentWithOTP(
    file: StaticString = #file,
    line: UInt = #line
) -> AnywayPayment {
    
    let payment = makeAnywayPayment(fields: [makeOTPField()])
    XCTAssert(hasOTPField(payment), "Expected to have OTP field.", file: file, line: line)
    return payment
}

private func makeAnywayPaymentField(
    _ id: AnywayPayment.Element.Field.ID = .string(anyMessage()),
    value: String = anyMessage(),
    title: String = anyMessage()
) -> AnywayPayment.Element.Field {
    
    .init(id: id, value: value, title: title)
}

private func makeAnywayPaymentFieldWithStringID(
    _ id: String = anyMessage(),
    value: String = anyMessage(),
    title: String = anyMessage()
) -> AnywayPayment.Element.Field {
    
    makeAnywayPaymentField(.string(id), value: value, title: title)
}

private func makeAnywayPaymentParameter(
    field: AnywayPayment.Element.Parameter.Field = makeAnywayPaymentElementParameterField(),
    masking: AnywayPayment.Element.Parameter.Masking = makeAnywayPaymentElementParameterMasking(),
    validation: AnywayPayment.Element.Parameter.Validation = makeAnywayPaymentElementParameterValidation(),
    uiAttributes: AnywayPayment.Element.Parameter.UIAttributes = makeAnywayPaymentElementParameterUIAttributes()
) -> AnywayPayment.Element.Parameter {
    
    .init(
        field: field,
        masking: masking,
        validation: validation,
        uiAttributes: uiAttributes
    )
}

private func makeAnywayPaymentParameterWithID(
    _ id: String = anyMessage()
) -> AnywayPayment.Element.Parameter {
    
    makeAnywayPaymentParameter(
        field: makeAnywayPaymentElementParameterField(id: id)
    )
}

private func makeAnywayPaymentElementParameterField(
    id: String = anyMessage(),
    value: String? = anyMessage()
) -> AnywayPayment.Element.Parameter.Field {
    
    .init(id: id, value: value)
}

private func makeAnywayPaymentElementParameterMasking(
    inputMask: String? = nil,
    mask: String? = nil
) -> AnywayPayment.Element.Parameter.Masking {
    
    .init(inputMask: inputMask, mask: mask)
}

private func makeAnywayPaymentElementParameterValidation(
    isRequired: Bool = true,
    maxLength: Int? = nil,
    minLength: Int? = nil,
    regExp: String = anyMessage()
) -> AnywayPayment.Element.Parameter.Validation {
    
    .init(
        isRequired: isRequired,
        maxLength: maxLength,
        minLength: minLength,
        regExp: regExp
    )
}

private func makeAnywayPaymentElementParameterUIAttributes(
    dataType: AnywayPayment.Element.Parameter.UIAttributes.DataType = .string,
    group: String? = nil,
    isPrint: Bool = true,
    phoneBook: Bool = false,
    isReadOnly: Bool = false,
    subGroup: String? = nil,
    subTitle: String? = nil,
    svgImage: String? = nil,
    title: String = anyMessage(),
    type: AnywayPayment.Element.Parameter.UIAttributes.FieldType = .input,
    viewType: AnywayPayment.Element.Parameter.UIAttributes.ViewType = .input
) -> AnywayPayment.Element.Parameter.UIAttributes {
    
    .init(
        dataType: dataType,
        group: group,
        isPrint: isPrint,
        phoneBook: phoneBook,
        isReadOnly: isReadOnly,
        subGroup: subGroup,
        subTitle: subTitle,
        svgImage: svgImage,
        title: title,
        type: type,
        viewType: viewType
    )
}

private func makeOTPField(
    value: String = anyMessage(),
    title: String = anyMessage()
) -> AnywayPayment.Element.Field {
    
    .init(id: .otp, value: value, title: title)
}

private func makeAnywayPaymentWithoutOTP(
    file: StaticString = #file,
    line: UInt = #line
) -> AnywayPayment {
    
    let payment = makeAnywayPayment()
    XCTAssertFalse(hasOTPField(payment), "Expected no OTP field.", file: file, line: line)
    return payment
}

private func makeFinalStepAnywayPayment(
    file: StaticString = #file,
    line: UInt = #line
) -> AnywayPayment {
    
    let payment = makeAnywayPayment(isFinalStep: true)
    XCTAssert(isFinalStep(payment), "Expected non final step payment.", file: file, line: line)
    return payment
}

private func makeNonFinalStepAnywayPayment(
    file: StaticString = #file,
    line: UInt = #line
) -> AnywayPayment {
    
    let payment = makeAnywayPayment(isFinalStep: false)
    XCTAssert(!isFinalStep(payment), "Expected non final step payment.", file: file, line: line)
    return payment
}

private func makeAnywayPaymentUpdate(
    fields: [AnywayPaymentUpdate.Field] = [],
    isFraudSuspected: Bool = false,
    infoMessage: String? = nil,
    isFinalStep: Bool = false,
    needOTP: Bool = false,
    needSum: Bool = false
) -> AnywayPaymentUpdate {
    
    makeAnywayPaymentUpdate(
        details: makeAnywayPaymentUpdateDetails(
            control: makeAnywayPaymentUpdateDetailsControl(
                isFinalStep: isFinalStep,
                isFraudSuspected: isFraudSuspected,
                needOTP: needOTP,
                needSum: needSum
            ),
            info: makeAnywayPaymentUpdateDetailsInfo(
                infoMessage: infoMessage
            )
        ),
        fields: fields
    )
}

private func makeAnywayPaymentUpdate(
    details: AnywayPaymentUpdate.Details = makeAnywayPaymentUpdateDetails(),
    fields: [AnywayPaymentUpdate.Field] = [],
    parameters: [AnywayPaymentUpdate.Parameter] = []
) -> AnywayPaymentUpdate {
    
    .init(
        details: details,
        fields: fields,
        parameters: parameters
    )
}

private func makeAnywayPaymentUpdateDetails(
    amounts: AnywayPaymentUpdate.Details.Amounts = makeAnywayPaymentUpdateDetailsAmounts(),
    control: AnywayPaymentUpdate.Details.Control = makeAnywayPaymentUpdateDetailsControl(),
    info: AnywayPaymentUpdate.Details.Info = makeAnywayPaymentUpdateDetailsInfo()
) -> AnywayPaymentUpdate.Details {
    
    .init(
        amounts: amounts,
        control: control,
        info: info
    )
}

private func makeAnywayPaymentUpdateDetailsAmounts(
    amount: Decimal? = nil,
    creditAmount: Decimal? = nil,
    currencyAmount: String? = nil,
    currencyPayee: String? = nil,
    currencyPayer: String? = nil,
    currencyRate: Decimal? = nil,
    debitAmount: Decimal? = nil,
    fee: Decimal? = nil
) -> AnywayPaymentUpdate.Details.Amounts {
    
    .init(
        amount: amount,
        creditAmount: creditAmount,
        currencyAmount: currencyAmount,
        currencyPayee: currencyPayee,
        currencyPayer: currencyPayer,
        currencyRate: currencyRate,
        debitAmount: debitAmount,
        fee: fee
    )
}

private func makeAnywayPaymentUpdateDetailsControl(
    isFinalStep: Bool = false,
    isFraudSuspected: Bool = false,
    needMake: Bool = false,
    needOTP: Bool = false,
    needSum: Bool = false
) -> AnywayPaymentUpdate.Details.Control {
    
    .init(
        isFinalStep: isFinalStep,
        isFraudSuspected: isFraudSuspected,
        needMake: needMake,
        needOTP: needOTP,
        needSum: needSum
    )
}

private func makeAnywayPaymentUpdateDetailsInfo(
    documentStatus: AnywayPaymentUpdate.Details.Info.DocumentStatus? = nil,
    infoMessage: String? = nil,
    payeeName: String? = nil,
    paymentOperationDetailID: Int? = nil,
    printFormType: String? = nil
) -> AnywayPaymentUpdate.Details.Info {
    
    .init(
        documentStatus: documentStatus,
        infoMessage: infoMessage,
        payeeName: payeeName,
        paymentOperationDetailID: paymentOperationDetailID,
        printFormType: printFormType
    )
}

private func makeAnywayPaymentUpdateField(
    _ name: String = anyMessage(),
    value: String = anyMessage(),
    title: String = anyMessage()
) -> AnywayPaymentUpdate.Field {
    
    .init(
        name: name,
        value: value,
        title: title,
        recycle: false,
        svgImage: nil,
        typeIdParameterList: nil
    )
}

private func makeAnywayPaymentAndUpdateFields(
    _ name: String = anyMessage(),
    value: String = anyMessage(),
    title: String = anyMessage()
) -> (update: AnywayPaymentUpdate.Field, updated: AnywayPayment.Element.Field) {
    
    let update = makeAnywayPaymentUpdateField(
        name,
        value: value,
        title: title
    )
    
    let updated = makeAnywayPaymentField(
        .string(name), value: value, title: title
    )
    
    return (update, updated)
}

private func makeAnywayPaymentUpdateParameter(
    field: AnywayPaymentUpdate.Parameter.Field = makeAnywayPaymentUpdateParameterField(),
    masking: AnywayPaymentUpdate.Parameter.Masking = makeAnywayPaymentUpdateParameterMasking(),
    validation: AnywayPaymentUpdate.Parameter.Validation = makeAnywayPaymentUpdateParameterValidation(),
    uiAttributes: AnywayPaymentUpdate.Parameter.UIAttributes = makeAnywayPaymentUpdateParameterUIAttributes()
) -> AnywayPaymentUpdate.Parameter {
    
    .init(
        field: field,
        masking: masking,
        validation: validation,
        uiAttributes: uiAttributes
    )
}

private func makeAnywayPaymentAndUpdateParameters(
    id: String = anyMessage(),
    value: String? = anyMessage(),
    inputMask: String? = nil,
    mask: String? = nil,
    isRequired: Bool = true,
    maxLength: Int? = nil,
    minLength: Int? = nil,
    regExp: String = anyMessage(),
    dataType: AnywayPaymentUpdate.Parameter.UIAttributes.DataType = .string,
    group: String? = nil,
    inputFieldType: AnywayPaymentUpdate.Parameter.UIAttributes.InputFieldType? = nil,
    isPrint: Bool = true,
    order: Int? = nil,
    phoneBook: Bool = false,
    isReadOnly: Bool = false,
    subGroup: String? = nil,
    subTitle: String? = nil,
    svgImage: String? = nil,
    title: String = anyMessage(),
    type: AnywayPaymentUpdate.Parameter.UIAttributes.FieldType = .input,
    viewType: AnywayPaymentUpdate.Parameter.UIAttributes.ViewType = .input
    
) -> (update: AnywayPaymentUpdate.Parameter, updated: AnywayPayment.Element.Parameter) {
    
    let (fieldUpdate, updatedField) = makeAnywayPaymentAndUpdateParameterField(
        id: id,
        value: value
    )
    let (maskingUpdate, updatedMasking) = makeAnywayPaymentAndUpdateParameterMasking(
        inputMask: inputMask,
        mask: mask
    )
    let (validationUpdate, updatedValidation) = makeAnywayPaymentAndUpdateParameterValidation(
        isRequired: isRequired,
        maxLength: maxLength,
        minLength: minLength,
        regExp: regExp
    )
    let (uiAttributesUpdate, updatedUIAttributes) = makeAnywayPaymentAndUpdateParameterUIAttributes(
        dataType: dataType,
        group: group,
        inputFieldType: inputFieldType,
        isPrint: isPrint,
        order: order,
        phoneBook: phoneBook,
        isReadOnly: isReadOnly,
        subGroup: subGroup,
        subTitle: subTitle,
        svgImage: svgImage,
        title: title,
        type: type,
        viewType: viewType
    )
    
    let update = makeAnywayPaymentUpdateParameter(
        field: fieldUpdate,
        masking: maskingUpdate,
        validation: validationUpdate,
        uiAttributes: uiAttributesUpdate
    )
    let updated = makeAnywayPaymentParameter(
        field: updatedField,
        masking: updatedMasking,
        validation: updatedValidation,
        uiAttributes: updatedUIAttributes
    )
    
    return (update, updated)
}

private func makeAnywayPaymentAndUpdateParameterField(
    id: String = anyMessage(),
    value: String? = nil
) -> (update: AnywayPaymentUpdate.Parameter.Field, updated: AnywayPayment.Element.Parameter.Field) {
    
    let update = makeAnywayPaymentUpdateParameterField(
        content: value,
        id: id
    )
    let updated = makeAnywayPaymentElementParameterField(
        id: id,
        value: value
    )
    
    return (update, updated)
}

private func makeAnywayPaymentAndUpdateParameterMasking(
    inputMask: String? = nil,
    mask: String? = nil
) -> (update: AnywayPaymentUpdate.Parameter.Masking, updated: AnywayPayment.Element.Parameter.Masking) {
    
    let update = makeAnywayPaymentUpdateParameterMasking(
        inputMask: inputMask,
        mask: mask
    )
    let updated = makeAnywayPaymentElementParameterMasking(
        inputMask: inputMask,
        mask: mask
    )
    
    return (update, updated)
}

private func makeAnywayPaymentAndUpdateParameterValidation(
    isRequired: Bool = true,
    maxLength: Int? = nil,
    minLength: Int? = nil,
    regExp: String = anyMessage()
) -> (update: AnywayPaymentUpdate.Parameter.Validation, updated: AnywayPayment.Element.Parameter.Validation) {
    
    let update = makeAnywayPaymentUpdateParameterValidation(
        isRequired: isRequired,
        maxLength: maxLength,
        minLength: minLength,
        rawLength: generateRandom11DigitNumber(),
        regExp: regExp
    )
    let updated = makeAnywayPaymentElementParameterValidation(
        isRequired: isRequired,
        maxLength: maxLength,
        minLength: minLength,
        regExp: regExp
    )
    
    return (update, updated)
}

private func makeAnywayPaymentAndUpdateParameterUIAttributes(
    dataType: AnywayPaymentUpdate.Parameter.UIAttributes.DataType = .string,
    group: String? = nil,
    inputFieldType: AnywayPaymentUpdate.Parameter.UIAttributes.InputFieldType? = nil,
    isPrint: Bool = true,
    order: Int? = nil,
    phoneBook: Bool = false,
    isReadOnly: Bool = false,
    subGroup: String? = nil,
    subTitle: String? = nil,
    svgImage: String? = nil,
    title: String = anyMessage(),
    type: AnywayPaymentUpdate.Parameter.UIAttributes.FieldType = .input,
    viewType: AnywayPaymentUpdate.Parameter.UIAttributes.ViewType = .input
) -> (update: AnywayPaymentUpdate.Parameter.UIAttributes, updated: AnywayPayment.Element.Parameter.UIAttributes) {
    
    let update = makeAnywayPaymentUpdateParameterUIAttributes(
        dataType: dataType,
        group: group,
        inputFieldType: inputFieldType,
        isPrint: isPrint,
        order: order,
        phoneBook: phoneBook,
        isReadOnly: isReadOnly,
        subGroup: subGroup,
        subTitle: subTitle,
        svgImage: svgImage,
        title: title,
        type: type,
        viewType: viewType
    )
    let updated = makeAnywayPaymentElementParameterUIAttributes(
        dataType: .init(with: dataType),
        group: group,
        isPrint: isPrint,
        phoneBook: phoneBook,
        isReadOnly: isReadOnly,
        subGroup: subGroup,
        subTitle: subTitle,
        svgImage: svgImage,
        title: title,
        type: .init(with: type),
        viewType: .init(with: viewType)
    )
    
    return (update, updated)
}

private extension AnywayPayment.Element.Parameter.UIAttributes.DataType {
    
    init(with dataType: AnywayPaymentUpdate.Parameter.UIAttributes.DataType) {
        
        switch dataType {
        case .string:
            self = .string
            
        case let .pairs(pairs):
            self = .pairs(pairs.map(Pair.init))
        }
    }
}

private extension AnywayPayment.Element.Parameter.UIAttributes.DataType.Pair {
    
    init(with pairs: AnywayPaymentUpdate.Parameter.UIAttributes.DataType.Pair) {
        
        self.init(key: pairs.key, value: pairs.value)
    }
}

private extension AnywayPayment.Element.Parameter.UIAttributes.FieldType {
    
    init(with fieldType: AnywayPaymentUpdate.Parameter.UIAttributes.FieldType) {
        
        switch fieldType {
        case .input:    self = .input
        case .select:   self = .select
        case .maskList: self = .maskList
        }
    }
}

private extension AnywayPayment.Element.Parameter.UIAttributes.ViewType {
    
    init(with viewType: AnywayPaymentUpdate.Parameter.UIAttributes.ViewType) {
        
        switch viewType {
        case .constant: self = .constant
        case .input:    self = .input
        case .output:   self = .output
        }
    }
}

private func makeAnywayPaymentUpdateParameterField(
    content: String? = nil,
    dataDictionary: String? = nil,
    dataDictionaryРarent: String? = nil,
    id: String = anyMessage()
) -> AnywayPaymentUpdate.Parameter.Field {
    
    .init(
        content: content,
        dataDictionary: dataDictionary,
        dataDictionaryРarent: dataDictionaryРarent,
        id: id
    )
}

private func makeAnywayPaymentUpdateParameterMasking(
    inputMask: String? = nil,
    mask: String? = nil
) -> AnywayPaymentUpdate.Parameter.Masking {
    
    .init(inputMask: inputMask, mask: mask)
}

private func makeAnywayPaymentUpdateParameterValidation(
    isRequired: Bool = true,
    maxLength: Int? = nil,
    minLength: Int? = nil,
    rawLength: Int = 0,
    regExp: String = anyMessage()
) -> AnywayPaymentUpdate.Parameter.Validation {
    
    .init(
        isRequired: isRequired,
        maxLength: maxLength,
        minLength: minLength,
        rawLength: rawLength,
        regExp: regExp
    )
}

private func makeAnywayPaymentUpdateParameterUIAttributes(
    dataType: AnywayPaymentUpdate.Parameter.UIAttributes.DataType = .string,
    group: String? = nil,
    inputFieldType: AnywayPaymentUpdate.Parameter.UIAttributes.InputFieldType? = nil,
    isPrint: Bool = true,
    order: Int? = nil,
    phoneBook: Bool = false,
    isReadOnly: Bool = false,
    subGroup: String? = nil,
    subTitle: String? = nil,
    svgImage: String? = nil,
    title: String = anyMessage(),
    type: AnywayPaymentUpdate.Parameter.UIAttributes.FieldType = .input,
    viewType: AnywayPaymentUpdate.Parameter.UIAttributes.ViewType = .input
) -> AnywayPaymentUpdate.Parameter.UIAttributes {
    
    .init(
        dataType: dataType,
        group: group,
        inputFieldType: inputFieldType,
        isPrint: isPrint,
        order: order,
        phoneBook: phoneBook,
        isReadOnly: isReadOnly,
        subGroup: subGroup,
        subTitle: subTitle,
        svgImage: svgImage,
        title: title,
        type: type,
        viewType: viewType
    )
}

private extension AnywayPayment.Element.Parameter {
    
    func updating(value: String?) -> Self {
        
        .init(
            field: .init(id: field.id, value: value),
            masking: masking,
            validation: validation,
            uiAttributes: uiAttributes
        )
    }
}
