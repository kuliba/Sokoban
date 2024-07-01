//
//  AnywayPaymentUpdateTests.swift
//
//
//  Created by Igor Malyarov on 04.04.2024.
//

import AnywayPaymentCore
import AnywayPaymentDomain
import XCTest

final class AnywayPaymentUpdateTests: XCTestCase {
    
    // MARK: - amount (core)
    
    func test_update_shouldNotAddAmountWidgetOnNeedSumFalseAndIsMultiSumFalse() {
        
        assert(
            makeAnywayPaymentWithoutAmount(),
            on: makeAnywayPaymentUpdate(needSum: false, isMultiSum: false)
        )
    }
    
    func test_update_shouldNotAddAmountWidgetOnNeedSumFalseAndIsMultiSumTrue() {
        
        assert(
            makeAnywayPaymentWithoutAmount(),
            on: makeAnywayPaymentUpdate(needSum: false, isMultiSum: true)
        )
    }
    
    func test_update_shouldSetFooterToAmountOnNeedSumTrueAndIsMultiSumFalse() {
        
        let payment = makeAnywayPaymentWithoutAmount()
        let update = makeAnywayPaymentUpdate(needSum: true, isMultiSum: false)
        
        XCTAssert(hasAmountFooter(updatePayment(payment, with: update)))
    }
    
    func test_update_shouldNotSetFooterToAmountOnNeedSumTrueAndIsMultiSumTrue() {
        
        let payment = makeAnywayPaymentWithoutAmount()
        let update = makeAnywayPaymentUpdate(needSum: true, isMultiSum: true)
        
        XCTAssertFalse(hasAmountFooter(updatePayment(payment, with: update)))
    }
    
    func test_update_shouldSetFooterToContinueOnNeedSumFalseAndIsMultiSumFalse() {
        
        let payment = makeAnywayPaymentWithAmount()
        let update = makeAnywayPaymentUpdate(needSum: false, isMultiSum: false)
        
        XCTAssertFalse(hasAmountFooter(updatePayment(payment, with: update)))
        XCTAssertTrue(hasContinueFooter(updatePayment(payment, with: update)))
    }
    
    func test_update_shouldSetFooterToContinueOnNeedSumFalseAndIsMultiSumTrue() {
        
        let payment = makeAnywayPaymentWithAmount()
        let update = makeAnywayPaymentUpdate(needSum: false, isMultiSum: true)
        
        XCTAssertFalse(hasAmountFooter(updatePayment(payment, with: update)))
        XCTAssertTrue(hasContinueFooter(updatePayment(payment, with: update)))
    }
    
    func test_update_shouldSetProductWidgetWithAccountIDFromOutline() {
        
        let payment = makeAnywayPaymentWithoutAmount()
        let update = makeAnywayPaymentUpdate(needSum: true)
        let (amount, currency, id) = (makeAmount(), anyMessage(), makeIntID())
        let core = makeOutlinePaymentCore(amount: amount, currency: currency, productID: id, productType: .account)
        let outline = makeAnywayPaymentOutline(core: core)
        
        let widgetProduct = makeProductWidget(updatePayment(payment, with: update, and: outline))
        
        XCTAssertNoDiff(widgetProduct, .init(
            currency: .init(currency),
            productID: id,
            productType: .account
        ))
    }
    
    func test_update_shouldSetProductWidgetWithCardIDFromOutline() {
        
        let payment = makeAnywayPaymentWithoutAmount()
        let update = makeAnywayPaymentUpdate(needSum: true)
        let (amount, currency, id) = (makeAmount(), anyMessage(), makeIntID())
        let core = makeOutlinePaymentCore(amount: amount, currency: currency, productID: id, productType: .card)
        let outline = makeAnywayPaymentOutline(core: core)
        
        let widgetCore = makeProductWidget(updatePayment(payment, with: update, and: outline))
        
        XCTAssertNoDiff(widgetCore, .init(
            currency: .init(currency),
            productID: id,
            productType: .card
        ))
    }
    
    private func makeProductWidget(
        _ payment: AnywayPayment
    ) -> AnywayElement.Widget.Product? {
        
        let cores: [AnywayElement.Widget.Product] = payment.elements.compactMap {
            
            guard case let .widget(.product(core)) = $0
            else { return nil }
            
            return core
        }
        
        return cores.first
    }
    
    // MARK: - complimentary fields
    
    func test_update_shouldAppendComplementaryFieldToEmpty() {
        
        let payment = makeAnywayPayment()
        let updateField = makeAnywayPaymentUpdateField("a", title: "aaa", value: "aa")
        let update = makeAnywayPaymentUpdate(fields: [updateField])
        let updated = makeAnywayPaymentField("a", value: "aa", title: "aaa")
        
        XCTAssertNoDiff(payment.elements, [])
        assert(payment, on: update) {
            
            $0.elements = [AnywayElement.field(updated)]
        }
    }
    
    func test_update_shouldAppendComplementaryFieldsToEmpty() {
        
        let payment = makeAnywayPayment()
        let update = makeAnywayPaymentUpdate(
            fields: [
                makeAnywayPaymentUpdateField("a", title: "aaa", value: "aa"),
                makeAnywayPaymentUpdateField("b", title: "bbb", value: "bb"),
                makeAnywayPaymentUpdateField("c", title: "ccc", value: "cc")
            ]
        )
        
        XCTAssertNoDiff(payment.elements, [])
        assert(payment, on: update) {
            
            $0.elements = [
                makeAnywayPaymentField("a", value: "aa", title: "aaa"),
                makeAnywayPaymentField("b", value: "bb", title: "bbb"),
                makeAnywayPaymentField("c", value: "cc", title: "ccc"),
            ].map(AnywayElement.field)
        }
    }
    
    func test_update_shouldAppendComplimentaryStringIDFieldToNonEmpty() {
        
        let field = makeAnywayPaymentField()
        let payment = makeAnywayPayment(fields: [field])
        let (fieldUpdate, updatedField) = makeAnywayPaymentAndUpdateFields()
        let update = makeAnywayPaymentUpdate(fields: [fieldUpdate])
        
        assert(payment, on: update) {
            
            let fields = [field].appending(updatedField)
            $0.elements = fields.map(AnywayElement.field)
        }
    }
    
    func test_update_shouldAppendComplimentaryStringIDFieldsToNonEmpty() {
        
        let field = makeAnywayPaymentField()
        let payment = makeAnywayPayment(fields: [field])
        let (fieldUpdate1, updatedField1) = makeAnywayPaymentAndUpdateFields()
        let (fieldUpdate2, updatedField2) = makeAnywayPaymentAndUpdateFields()
        let update = makeAnywayPaymentUpdate(fields: [
            fieldUpdate1, fieldUpdate2
        ])
        
        assert(payment, on: update) {
            
            let fields = [field, updatedField1, updatedField2]
            $0.elements = fields.map(AnywayElement.field)
        }
    }
    
    // MARK: - footer
    
    func test_update_shouldUpdateAmount() {
        
        let state = makeAnywayPayment(
            amount: 123.45,
            elements: [makeProductWidgetElement()],
            footer: .amount
        )
        
        assert(
            state,
            on: makeAnywayPaymentUpdate(amount: 567.89, needSum: true)
        ) {
            $0.amount = 567.89
        }
    }
    
    #warning("add test for fee & debitAmount")

    func test_update_shouldNotAddProductOnExistingProduct() {
        
        let amount = Decimal(567.89)
        let state = makeAnywayPayment(
            amount: 123.45,
            elements: [makeProductWidgetElement()],
            footer: .amount
        )
        
        assert(
            state,
            on: makeAnywayPaymentUpdate(amount: amount, needSum: true)
        ) {
            $0.amount = amount
        }
    }

    func test_update_shouldFlipFooterToContinueOnNeedSumTrueOnFinalStep() {
        
        let amount = Decimal(567.89)
        let state = makeAnywayPayment(
            amount: amount,
            elements: [makeProductWidgetElement()],
            footer: .amount,
            isFinalStep: false
        )
        
        assert(
            state,
            on: makeAnywayPaymentUpdate(amount: amount, isFinalStep: true, needSum: true)
        ) {
            $0.footer = .continue
            $0.isFinalStep = true
        }
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
    
    // MARK: - non-complimentary (primary) fields
    
    func test_update_shouldNotChangeStringIDFieldWithSameValueInNonComplementaryFields() {
        
        let (id, value, title) = ("abc123", "aaa", "bb")
        let field = makeAnywayPaymentField(id: id, value: value, title: title)
        let payment = makeAnywayPayment(fields: [field])
        let updateField = makeAnywayPaymentUpdateField(id, title: title, value: value)
        let update = makeAnywayPaymentUpdate(fields: [updateField])
        
        assert(payment, on: update)
    }
    
    func test_update_shouldChangeStringIDFieldWithDifferentValueInNonComplementaryFields() {
        
        let id = anyMessage()
        let field = makeAnywayPaymentField(id: id)
        let payment = makeAnywayPayment(fields: [field])
        let (fieldUpdate, updatedField) = makeAnywayPaymentAndUpdateFields(id, value: "aa", title: "bbb")
        let update = makeAnywayPaymentUpdate(fields: [fieldUpdate])
        
        assert(payment, on: update) {
            
            $0.elements = [.field(updatedField)]
        }
    }
    
    func test_update_shouldUpdateExistingFieldOnUpdateWithDifferentValue() {
        
        let field = makeAnywayPaymentField(id: "e1")
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
    
    func test_update_withSumSTrsAndNeedSumFalse() {
        
        let payment = makeAnywayPayment()
        let update = makeAnywayPaymentUpdate(
            details: .init(
                amounts: makeDetailsAmounts(amount: 4273.87),
                control: makeDetailsControl(needSum: false),
                info: makeDetailsInfo()
            ),
            fields: [
                makeField(name: "SumSTrs", value: "4273.87", title: "Сумма")
            ],
            parameters: []
        )
        
        assert(payment, on: update) {
            
            $0.amount = 4273.87
            let field = makeAnywayPaymentField("SumSTrs", value: "4273.87", title: "Сумма")
            $0.elements = [.field(field)]
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
        let (fieldUpdate1, _) = makeAnywayPaymentAndUpdateFields()
        let (fieldUpdate2, _) = makeAnywayPaymentAndUpdateFields()
        
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
        XCTAssertNil(outline.fields[.init(parameterID)])
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
        XCTAssertNoDiff(outline.fields[.init(parameterID)], .init(outlinedValue), "Expected outlined value \(outlinedValue) for parameterID \(parameterID).")
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
            
            $0.elements = [parameter1, parameter2, updatedParameter].map(AnywayElement.parameter)
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
            
            $0.elements = [updatedParameter1, updatedParameter2].map(AnywayElement.parameter)
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
            
            let appending = [updatedParameter1, updatedParameter2].map(AnywayElement.parameter)
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
            
            let appending = [updatedParameter1, updatedParameter2].map(AnywayElement.parameter)
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
            
            let appending = [updatedParameter1, updatedParameter2].map(AnywayElement.parameter)
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
            
            let appending = [updatedParameter1, updatedParameter2].map(AnywayElement.parameter)
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
                .map(AnywayElement.parameter)
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
                .map(AnywayElement.parameter)
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
            $0.elements = complimentaryFields.map(AnywayElement.field)
            + parameters.map(AnywayElement.parameter)
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
            + complimentaryFields.map(AnywayElement.field)
            + parameters.map(AnywayElement.parameter)
        }
    }
    
    func test_update_shouldUpdateExistingParameterOnUpdateWithDifferentValue() {
        
        let id = anyMessage()
        let parameter = makeAnywayPaymentParameter(id: id)
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
        let parameter = makeAnywayPaymentParameter(id: matchingID)
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
        let field = makeAnywayPaymentField(id: matchingFieldID)
        let parameter = makeAnywayPaymentParameter(id: matchingParameterID)
        let payment = makeAnywayPayment(elements: [
            .field(field),
            .parameter(parameter)
        ])
        
        let (newFieldValue, newFieldTitle) = (anyMessage(), anyMessage())
        let fieldUpdate = makeAnywayPaymentUpdateField(
            matchingFieldID,
            title: newFieldTitle,
            value: newFieldValue
        )
        
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
                    makeAnywayPaymentField(
                        .init(matchingFieldID),
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
            dataType: .pairs(.init(key: "a", value: "1"), [.init(key: "a", value: "1")]),
            group: nil,
            isPrint: true,
            type: .input,
            viewType: .constant
        )
        
        XCTAssertNoDiff(update.field.content, value)
        XCTAssertNoDiff(parameter.field.value, .init(value))
        
        XCTAssertNoDiff(update.uiAttributes.dataType, .pairs(.init(key: "a", value: "1"), [.init(key: "a", value: "1")]))
        XCTAssertNoDiff(parameter.uiAttributes.dataType, .pairs(.init(key: "a", value: "1"), [.init(key: "a", value: "1")]))
        
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
            dataType: .pairs(.init(key: "a", value: "1"), [.init(key: "a", value: "1"), .init(key: "b", value: "c")]),
            group: "group",
            isPrint: false,
            type: .maskList,
            viewType: .output
        )
        
        XCTAssertNoDiff(update.uiAttributes.dataType, .pairs(.init(key: "a", value: "1"), [.init(key: "a", value: "1"), .init(key: "b", value: "c")]))
        XCTAssertNoDiff(parameter.uiAttributes.dataType, .pairs(.init(key: "a", value: "1"), [.init(key: "a", value: "1"), .init(key: "b", value: "c")]))
        
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
        and outline: AnywayPaymentOutline = makeAnywayPaymentOutline()
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
    
    private func makeDetailsAmounts(
        amount: Decimal? = nil,
        creditAmount: Decimal? = nil,
        currencyAmount: String? = nil,
        currencyPayee: String? = nil,
        currencyPayer: String? = nil,
        currencyRate: Decimal? = nil,
        debitAmount: Decimal? = nil,
        fee: Decimal? = nil
    ) -> AnywayPaymentUpdate.Details.Amounts {
        
        return .init(
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
    
    private func makeDetailsControl(
        isFinalStep: Bool = false,
        isFraudSuspected: Bool = false,
        isMultiSum: Bool = false,
        needOTP: Bool = false,
        needSum: Bool = false
    ) -> AnywayPaymentUpdate.Details.Control {
        
        return .init(
            isFinalStep: isFinalStep,
            isFraudSuspected: isFraudSuspected,
            isMultiSum: isMultiSum,
            needOTP: needOTP,
            needSum: needSum
        )
    }
    
    private func makeDetailsInfo(
        documentStatus: AnywayPaymentUpdate.Details.Info.DocumentStatus? = nil,
        infoMessage: String? = nil,
        payeeName: String? = nil,
        paymentOperationDetailID: Int? = nil,
        printFormType: String? = nil
    ) -> AnywayPaymentUpdate.Details.Info {
        
        return .init(
            documentStatus: documentStatus,
            infoMessage: infoMessage,
            payeeName: payeeName,
            paymentOperationDetailID: paymentOperationDetailID,
            printFormType: printFormType
        )
    }
    
    private func makeField(
        name: String,
        value: String,
        title: String,
        icon: AnywayPaymentUpdate.Icon? = nil
    ) -> AnywayPaymentUpdate.Field {
        
        return .init(
            name: name,
            value: value,
            title: title,
            icon: icon
        )
    }
}

private extension AnywayPayment {
    
    subscript(parameterID id: String) -> AnywayElement.Parameter? {
        
        elements.compactMap {
            
            guard case let .parameter(parameter) = $0,
                  parameter.field.id == .init(id)
            else { return nil }
            
            return parameter
        }
        .first
    }
}
