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
        let updated = updatePayment(makeAnywayPaymentWithoutAmount(), with: update)
        
        XCTAssert(hasAmountField(updated))
    }
    
    func test_update_shouldRemoveAmountFieldOnNeedSumFalse() {
        
        let update = makeAnywayPaymentUpdate(needSum: false)
        let updated = updatePayment(makeAnywayPaymentWithAmount(), with: update)
        
        XCTAssertFalse(hasAmountField(updated))
    }
    
    // MARK: - complimentary fields
    
    func test_update_shouldAppendComplementaryFieldToEmpty() {
        
        let payment = makeAnywayPayment()
        let updateField = makeAnywayPaymentUpdateField("a", value: "aa", title: "aaa")
        let update = makeAnywayPaymentUpdate(fields: [updateField])
        let updated = makeAnywayPaymentField("a", value: "aa", title: "aaa")
        
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
                .init(id: "a", value: "aa", title: "aaa"),
                .init(id: "b", value: "bb", title: "bbb"),
                .init(id: "c", value: "cc", title: "ccc"),
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
        let updated = updatePayment(makeAnywayPaymentWithoutFraudSuspected(), with: update)
        
        XCTAssert(isFraudSuspected(updated))
    }
    
    func test_update_shouldRemoveFraudSuspectedFieldOnFraudSuspectedFalse() {
        
        let update = makeAnywayPaymentUpdate(isFraudSuspected: false)
        let updated = updatePayment(makeAnywayPaymentWithFraudSuspected(), with: update)
        
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
        let updated = updatePayment(makeNonFinalStepAnywayPayment(), with: update)
        
        XCTAssert(isFinalStep(updated))
    }
    
    func test_update_shouldSetIsFinalStepFlagOnIsFinalStepFalse() {
        
        let update = makeAnywayPaymentUpdate(isFinalStep: false)
        let updated = updatePayment(makeFinalStepAnywayPayment(), with: update)
        
        XCTAssertFalse(isFinalStep(updated))
    }
    
    // MARK: - infoMessage
    
    func test_update_shouldNotChangeInfoMessageOnNilInfoMessage() {
        
        assert(
            makeAnywayPayment(),
            on: makeAnywayPaymentUpdate(infoMessage: nil)
        )
    }
    
    func test_update_shouldChangeInfoMessageOnNonNilInfoMessage() {
        
        let message = anyMessage()
        
        assert(
            makeAnywayPayment(),
            on: makeAnywayPaymentUpdate(infoMessage: message)
        ) {
            $0.infoMessage = message
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
        let updated = updatePayment(makeAnywayPaymentWithoutOTP(), with: update)
        
        XCTAssert(hasOTPField(updated))
    }
    
    func test_update_shouldRemoveOTPFieldOnNeedOTPFalse() {
        
        let update = makeAnywayPaymentUpdate(needOTP: false)
        let updated = updatePayment(makeAnywayPaymentWithOTP(), with: update)
        
        XCTAssertFalse(hasOTPField(updated))
    }
    
    func test_update_shouldAppendOTPFieldAfterEmptyComplementaryFieldsOnNeedOTPTrue() {
        
        let payment = makeAnywayPaymentWithoutOTP()
        let update = makeAnywayPaymentUpdate(
            fields: [],
            needOTP: true
        )
        
        let updated = updatePayment(payment, with: update)
        
        assertOTPisLast(in: updated)
    }
    
    func test_update_shouldAppendOTPFieldAfterComplementaryFieldsOnNeedOTPTrue() {
        
        let payment = makeAnywayPaymentWithoutOTP()
        let (fieldUpdate1, updatedField1) = makeAnywayPaymentAndUpdateFields()
        let (fieldUpdate2, updatedField2) = makeAnywayPaymentAndUpdateFields()
        
        let update = makeAnywayPaymentUpdate(
            fields: [fieldUpdate1, fieldUpdate2],
            needOTP: true
        )
        
        let updated = updatePayment(payment, with: update)
        
        assertOTPisLast(in: updated)
    }
    
    // MARK: - parameters
    
    func test_update_shouldSetParameterValueToNilOnNilUpdateValueAndMissingOutline() throws {
        
        let payment = makeAnywayPayment(parameters: [])
        let parameterID = anyMessage()
        let (parameterUpdate, _) = makeAnywayPaymentAndUpdateParameters(
            id: parameterID,
            value: nil
        )
        let update = makeAnywayPaymentUpdate(parameters: [parameterUpdate])
        let outline = makeAnywayPaymentOutline()
        
        let updated = updatePayment(payment, with: update, and: outline)
        let parameter = try XCTUnwrap(updated[parameterID: parameterID], "Expected parameter with id \(parameterID), but got nil instead.")
        
        XCTAssertNil(parameter.field.value)
        XCTAssertNil(outline[.init(parameterID)])
    }
    
    func test_update_shouldSetParameterValueToOutlinedOnNilUpdateValue() throws {
        
        let parameterID = anyMessage()
        let outlinedValue = anyMessage()
        let payment = makeAnywayPayment()
        let (parameterUpdate, _) = makeAnywayPaymentAndUpdateParameters(
            id: parameterID,
            value: nil
        )
        let update = makeAnywayPaymentUpdate(parameters: [parameterUpdate])
        let outline = makeAnywayPaymentOutline([parameterID: outlinedValue])
        
        let updated = updatePayment(payment, with: update, and: outline)
        let parameter = try XCTUnwrap(updated[parameterID: parameterID], "Expected parameter with id \(parameterID), but got nil instead.")
        
        XCTAssertNoDiff(parameter.field.value, .init(outlinedValue), "Expected parameter value set to outlined.")
        XCTAssertNoDiff(outline[.init(parameterID)], .init(outlinedValue), "Expected outlined value \(outlinedValue) for parameterID \(parameterID).")
        XCTAssertNil(parameterUpdate.field.content, "Expected value to be nil.")
    }
    
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
    
    func test_update_shouldUpdateElementsOnMatchingIDFieldUpdateWithDifferentValue() {
        
        let matchingFieldID = anyMessage()
        let matchingParameterID = anyMessage()
        let field = makeAnywayPaymentFieldWithStringID(matchingFieldID)
        let parameter = makeAnywayPaymentParameterWithID(matchingParameterID)
        let payment = makeAnywayPayment(elements: [
            .field(field),
            .parameter(parameter)
        ])
        
        let (newFieldValue, newFieldTitle) = (anyMessage(), anyMessage())
        let fieldUpdate = makeAnywayPaymentUpdateField(matchingFieldID, value: newFieldValue, title: newFieldTitle)
        
        let newParameterValue = anyMessage()
        let parameterFieldUpdate = makeAnywayPaymentUpdateField(matchingParameterID, value: newParameterValue)
        let (parameterUpdate2, updatedParameter2) = makeAnywayPaymentAndUpdateParameters()
        
        let update = makeAnywayPaymentUpdate(
            fields: [fieldUpdate, parameterFieldUpdate],
            parameters: [parameterUpdate2]
        )
        
        assert(payment, on: update) {
            
            $0.elements = [
                .field(
                    .init(
                        id: .init(matchingFieldID),
                        value: .init(newFieldValue),
                        title: newFieldTitle
                    )
                ),
                .parameter(parameter.updating(value: newParameterValue)),
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
        XCTAssertNoDiff(parameter.field.value, .init(value))
        
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
    
    private func updatePayment(
        _ payment: AnywayPayment,
        with update: AnywayPaymentUpdate,
        and outline: AnywayPayment.Outline = [:]
    ) -> AnywayPayment {
        
        payment.update(with: update, and: outline)
    }
    
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
        
        let received = updatePayment(payment, with: update)
        
        XCTAssertNoDiff(
            received, expected,
            "\nExpected \(expected), but got \(received) instead.",
            file: file, line: line
        )
    }
}

private extension AnywayPayment {
    
    subscript(parameterID id: String) -> Element.Parameter? {
        
        elements.compactMap {
            
            guard case let .parameter(parameter) = $0,
                  parameter.field.id == .init(id)
            else { return nil }

            return parameter
        }
        .first
    }
}
