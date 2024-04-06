//
//  UpdateAnywayPaymentTests.swift
//
//
//  Created by Igor Malyarov on 04.04.2024.
//

import AnywayPaymentCore
import XCTest

struct AnywayPayment: Equatable {
    
    var elements: [Element]
    let hasAmount: Bool
    let isFinalStep: Bool
    let isFraudSuspected: Bool
    var status: Status?
}

extension AnywayPayment {
    
    enum Element: Equatable {
        
        case field(Field)
        case parameter(Parameter)
    }
    
    enum Status: Equatable {
        
        case infoMessage(String)
    }
}


extension AnywayPayment.Element {
    
    struct Field: Identifiable, Equatable {
        
        let id: ID
        let value: String
        let title: String
    }
    
    struct Parameter: Equatable {}
}

extension AnywayPayment.Element.Field {
    
    enum ID: Hashable {
        
        case otp
        case string(String)
    }
}

extension AnywayPayment {
    
    func update(with update: AnywayPaymentUpdate) -> Self {
        
        let infoMessage = update.details.info.infoMessage
        let status = infoMessage.map(AnywayPayment.Status.infoMessage)
        
        var elements = elements
        elements.update(with: update)
        
        let otp = Element.Field(id: .otp, value: "", title: "")
        elements[id: .otp] = update.details.control.needOTP ? .field(otp) : nil
        
        return .init(
            elements: elements,
            hasAmount: update.details.control.needSum,
            isFinalStep: update.details.control.isFinalStep,
            isFraudSuspected: update.details.control.isFraudSuspected,
            status: status
        )
    }
}

private extension Array where Element == AnywayPayment.Element {
    
    subscript(id id: Element.Field.ID) -> Element? {
        
        get { firstIndex(matching: id).map { self[$0] } }
        
        set {
            guard let index = firstIndex(matching: id)
            else {
                if let newValue { append(newValue) }
                return
            }
            
            if let newValue {
                if case let .field(field) = newValue, field.id == id {
                    self[index] = newValue
                } else {
                    append(newValue)
                }
            } else {
                remove(at: index)
            }
        }
    }
    
    func firstIndex(
        matching id: AnywayPayment.Element.Field.ID
    ) -> Self.Index? {
        
        firstIndex {
            
            guard let fieldID = $0.fieldID else { return false }
            
            return fieldID == id
        }
    }
}

private extension Array where Element == AnywayPayment.Element {
    
    mutating func update(
        with update: AnywayPaymentUpdate
    ) {
        updatePrimaryFields(from: update.fields)
        appendComplementaryFields(from: update.fields)
        appendParameters(from: update.parameters)
    }
    
    mutating func updatePrimaryFields(
        from updateFields: [AnywayPaymentUpdate.Field]
    ) {
        let updateFields = Dictionary(
            uniqueKeysWithValues: updateFields.map { ($0.name, $0) }
        )
        
        self = map {
            
            guard let id = $0.fieldStringID,
                  let matching = updateFields[id]
            else { return $0 }
            
            return .field(.init(
                id: .string(id),
                value: matching.value,
                title: matching.title
            ))
        }
    }
    
    mutating func appendComplementaryFields(
        from updateFields: [AnywayPaymentUpdate.Field]
    ) {
        let existingIDs = stringFieldIDs
        let complimentary: [Element] = updateFields
            .filter { !existingIDs.contains($0.name) }
            .map(Element.Field.init)
            .map(Element.field)
        
        self.append(contentsOf: complimentary)
    }
    
    private var stringFieldIDs: [String] {
        
        compactMap(\.fieldStringID)
    }
    
    mutating func appendParameters(
        from updateParameters: [AnywayPaymentUpdate.Parameter]
    ) {
        let parameters = updateParameters.map(AnywayPayment.Element.Parameter.init)
        append(contentsOf: parameters.map(Element.parameter))
    }
}

private extension AnywayPayment.Element {
    
    var fieldID: Field.ID? {
        
        guard case let .field(field) = self else { return nil }
        
        return field.id
    }
    
    var fieldStringID: String? {
        
        guard case let .string(string) = fieldID
        else { return nil }
        
        return string
    }
}

private extension AnywayPayment.Element.Field {
    
    init(_ field: AnywayPaymentUpdate.Field) {
        
        self.init(
            id: .string(field.name),
            value: field.value,
            title: field.title
        )
    }
}

private extension AnywayPayment.Element.Parameter {
    
    init(_ field: AnywayPaymentUpdate.Parameter) {
        
        self.init()
    }
}

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
        let updateField = makeAnywayPaymentUpdateField()
        let update = makeAnywayPaymentUpdate(fields: [updateField])
        
        assert(payment, on: update) {
            
            let fields = [field].appending(updateField.field)
            $0.elements = fields.map(AnywayPayment.Element.field)
        }
    }
    
    func test_update_shouldAppendComplimentaryStringIDFieldsToNonEmpty() {
        
        let field = makeAnywayPaymentFieldWithStringID()
        let payment = makeAnywayPayment(fields: [field])
        let (updateField1, updateField2) = (makeAnywayPaymentUpdateField(), makeAnywayPaymentUpdateField())
        let update = makeAnywayPaymentUpdate(fields: [
            updateField1, updateField2
        ])
        
        assert(payment, on: update) {
            
            let fields = [field, updateField1.field, updateField2.field]
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
        
        let field = makeAnywayPaymentFieldWithStringID("abc123")
        let payment = makeAnywayPayment(fields: [field])
        let updateField = makeAnywayPaymentUpdateField("abc123", value: "aa", title: "bbb")
        let update = makeAnywayPaymentUpdate(fields: [updateField])
        let updated = makeAnywayPaymentField(.string("abc123"), value: "aa", title: "bbb")
        
        assert(payment, on: update) {
            
            $0.elements = [.field(updated)]
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
        let emptyFields = [AnywayPaymentUpdate.Field]()
        let update = makeAnywayPaymentUpdate(
            fields: emptyFields,
            needOTP: true
        )
        
        let updated = payment.update(with: update)
        
        assertOTP(in: updated, precedes: emptyFields)
    }
    
    func test_update_shouldAppendOTPFieldAfterComplementaryFieldsOnNeedOTPTrue() {
        
        let payment = makeAnywayPaymentWithoutOTP()
        let updateFields = [
            makeAnywayPaymentUpdateField(),
            makeAnywayPaymentUpdateField(),
        ]
        let update = makeAnywayPaymentUpdate(
            fields: updateFields,
            needOTP: true
        )
        
        let updated = payment.update(with: update)
        
        assertOTP(in: updated, precedes: updateFields)
    }
    
    // MARK: - parameters
    
    func test_update_shouldAppendParameterToEmpty() {
        
        let payment = makeAnywayPayment(parameters: [])
        let updateParameter = makeAnywayPaymentUpdateParameter()
        let update = makeAnywayPaymentUpdate(parameters: [updateParameter])
        
        assert(payment, on: update) {
            
            $0.elements = [.parameter(updateParameter.parameter)]
        }
    }
    
    func test_update_shouldAppendParameterToOneField() {
        
        let field = makeAnywayPaymentField()
        let payment = makeAnywayPayment(fields: [field])
        let updateParameter = makeAnywayPaymentUpdateParameter()
        let update = makeAnywayPaymentUpdate(parameters: [updateParameter])
        
        assert(payment, on: update) {
            
            $0.elements = [.field(field), .parameter(updateParameter.parameter)]
        }
    }
    
    func test_update_shouldAppendParameterToTwoFields() {
        
        let field1 = makeAnywayPaymentField()
        let field2 = makeAnywayPaymentField()
        let payment = makeAnywayPayment(fields: [field1, field2])
        let updateParameter = makeAnywayPaymentUpdateParameter()
        let update = makeAnywayPaymentUpdate(parameters: [updateParameter])
        
        assert(payment, on: update) {
            
            $0.elements = [.field(field1), .field(field2), .parameter(updateParameter.parameter)]
        }
    }
    
    func test_update_shouldAppendParameterToFieldAndParameter() {
        
        let field = makeAnywayPaymentField()
        let parameter = makeAnywayPaymentParameter()
        let payment = makeAnywayPayment(
            elements: [.field(field), .parameter(parameter)]
        )
        let updateParameter = makeAnywayPaymentUpdateParameter()
        let update = makeAnywayPaymentUpdate(parameters: [updateParameter])
        
        assert(payment, on: update) {
            
            $0.elements = [.field(field), .parameter(parameter), .parameter(updateParameter.parameter)]
        }
    }
    
    func test_update_shouldAppendParameterToParameterAndField() {
        
        let parameter = makeAnywayPaymentParameter()
        let field = makeAnywayPaymentField()
        let payment = makeAnywayPayment(
            elements: [.parameter(parameter), .field(field)]
        )
        let updateParameter = makeAnywayPaymentUpdateParameter()
        let update = makeAnywayPaymentUpdate(parameters: [updateParameter])
        
        assert(payment, on: update) {
            
            $0.elements = [.parameter(parameter), .field(field), .parameter(updateParameter.parameter)]
        }
    }
    
    func test_update_shouldAppendParameterToOneParameter() {
        
        let parameter = makeAnywayPaymentParameter()
        let payment = makeAnywayPayment(parameters: [parameter])
        let updateParameter = makeAnywayPaymentUpdateParameter()
        let update = makeAnywayPaymentUpdate(parameters: [updateParameter])
        
        assert(payment, on: update) {
            
            $0.elements = [.parameter(parameter), .parameter(updateParameter.parameter)]
        }
    }
    
    func test_update_shouldAppendParameterToTwoParameters() {
        
        let parameter1 = makeAnywayPaymentParameter()
        let parameter2 = makeAnywayPaymentParameter()
        let payment = makeAnywayPayment(parameters: [parameter1, parameter2])
        let updateParameter = makeAnywayPaymentUpdateParameter()
        let update = makeAnywayPaymentUpdate(parameters: [updateParameter])
        
        assert(payment, on: update) {
            
            $0.elements = [parameter1, parameter2, updateParameter.parameter]
                .map(AnywayPayment.Element.parameter)
        }
    }
    
    func test_update_shouldAppendTwoParametersToEmpty() {
        
        let payment = makeAnywayPayment(parameters: [])
        let updateParameter1 = makeAnywayPaymentUpdateParameter()
        let updateParameter2 = makeAnywayPaymentUpdateParameter()
        let update = makeAnywayPaymentUpdate(
            parameters: [updateParameter1, updateParameter2]
        )
        
        assert(payment, on: update) {
            
            $0.elements = [updateParameter1, updateParameter2]
                .map(\.parameter)
                .map(AnywayPayment.Element.parameter)
        }
    }
    
    func test_update_shouldAppendTwoParametersToOneField() {
        
        let field = makeAnywayPaymentField()
        let payment = makeAnywayPayment(fields: [field])
        let updateParameter1 = makeAnywayPaymentUpdateParameter()
        let updateParameter2 = makeAnywayPaymentUpdateParameter()
        let update = makeAnywayPaymentUpdate(
            parameters: [updateParameter1, updateParameter2]
        )
        
        assert(payment, on: update) {
            
            let appending = [updateParameter1, updateParameter2]
                .map(\.parameter)
                .map(AnywayPayment.Element.parameter)
            $0.elements = [.field(field)] + appending
        }
    }
    
    func test_update_shouldAppendTwoParametersToTwoFields() {
        
        let field1 = makeAnywayPaymentField()
        let field2 = makeAnywayPaymentField()
        let payment = makeAnywayPayment(fields: [field1, field2])
        let updateParameter1 = makeAnywayPaymentUpdateParameter()
        let updateParameter2 = makeAnywayPaymentUpdateParameter()
        let update = makeAnywayPaymentUpdate(
            parameters: [updateParameter1, updateParameter2]
        )
        
        assert(payment, on: update) {
            
            let appending = [updateParameter1, updateParameter2]
                .map(\.parameter)
                .map(AnywayPayment.Element.parameter)
            $0.elements = [.field(field1), .field(field2)] + appending
        }
    }
    
    func test_update_shouldAppendTwoParametersToFieldAndParameter() {
        
        let field = makeAnywayPaymentField()
        let parameter = makeAnywayPaymentParameter()
        let payment = makeAnywayPayment(
            elements: [.field(field), .parameter(parameter)]
        )
        let updateParameter1 = makeAnywayPaymentUpdateParameter()
        let updateParameter2 = makeAnywayPaymentUpdateParameter()
        let update = makeAnywayPaymentUpdate(
            parameters: [updateParameter1, updateParameter2]
        )
        
        assert(payment, on: update) {
            
            let appending = [updateParameter1, updateParameter2]
                .map(\.parameter)
                .map(AnywayPayment.Element.parameter)
            $0.elements = [.field(field), .parameter(parameter)] + appending
        }
    }
    
    func test_update_shouldAppendTwoParametersToParameterAndField() {
        
        let parameter = makeAnywayPaymentParameter()
        let field = makeAnywayPaymentField()
        let payment = makeAnywayPayment(
            elements: [.parameter(parameter), .field(field)]
        )
        let updateParameter1 = makeAnywayPaymentUpdateParameter()
        let updateParameter2 = makeAnywayPaymentUpdateParameter()
        let update = makeAnywayPaymentUpdate(
            parameters: [updateParameter1, updateParameter2]
        )
        
        assert(payment, on: update) {
            
            let appending = [updateParameter1, updateParameter2]
                .map(\.parameter)
                .map(AnywayPayment.Element.parameter)
            $0.elements = [.parameter(parameter), .field(field)] + appending
        }
    }
    
    func test_update_shouldAppendTwoParametersToOneParameter() {
        
        let parameter = makeAnywayPaymentParameter()
        let payment = makeAnywayPayment(parameters: [parameter])
        let updateParameter1 = makeAnywayPaymentUpdateParameter()
        let updateParameter2 = makeAnywayPaymentUpdateParameter()
        let update = makeAnywayPaymentUpdate(
            parameters: [updateParameter1, updateParameter2]
        )
        
        assert(payment, on: update) {
            
            let appending = [updateParameter1, updateParameter2].map(\.parameter)
            $0.elements = ([parameter] + appending)
                .map(AnywayPayment.Element.parameter)
        }
    }
    
    func test_update_shouldAppendTwoParametersToTwoParameters() {
        
        let parameter1 = makeAnywayPaymentParameter()
        let parameter2 = makeAnywayPaymentParameter()
        let payment = makeAnywayPayment(parameters: [parameter1, parameter2])
        let updateParameter1 = makeAnywayPaymentUpdateParameter()
        let updateParameter2 = makeAnywayPaymentUpdateParameter()
        let update = makeAnywayPaymentUpdate(
            parameters: [updateParameter1, updateParameter2]
        )
        
        assert(payment, on: update) {
            
            let appending = [updateParameter1, updateParameter2].map(\.parameter)
            $0.elements = ([parameter1, parameter2] + appending)
                .map(AnywayPayment.Element.parameter)
        }
    }
    
    func test_update_shouldAppendFieldAndParameterToEmptyOnUpdateWithParameterAndComplimentoryField() {
        
        let payment = makeAnywayPayment(elements: [])
        let updateField = makeAnywayPaymentUpdateField("a", value: "aa", title: "aaa")
        let updateParameter = makeAnywayPaymentUpdateParameter()
        let update = makeAnywayPaymentUpdate(
            fields: [updateField],
            parameters: [updateParameter]
        )
        
        assert(payment, on: update) {
            
            $0.elements = [updateField.field].map(AnywayPayment.Element.field)
            + [updateParameter.parameter].map(AnywayPayment.Element.parameter)
        }
    }
    
    func test_update_shouldAppendElementsToEmptyOnUpdateWithParametersAndComplimentoryFields() {
        
        let payment = makeAnywayPayment(elements: [])
        let updateField1 = makeAnywayPaymentUpdateField("a", value: "aa", title: "aaa")
        let updateField2 = makeAnywayPaymentUpdateField("1", value: "11", title: "111")
        let updateParameter1 = makeAnywayPaymentUpdateParameter()
        let updateParameter2 = makeAnywayPaymentUpdateParameter()
        let update = makeAnywayPaymentUpdate(
            fields: [updateField1, updateField2],
            parameters: [updateParameter1, updateParameter2]
        )
        
        assert(payment, on: update) {
            
            let complimentaryFields = [updateField1, updateField2].map(\.field)
            let parameters = [updateParameter1, updateParameter2].map(\.parameter)
            $0.elements = complimentaryFields.map(AnywayPayment.Element.field)
            + parameters.map(AnywayPayment.Element.parameter)
        }
    }
    
    func test_update_shouldAppendFieldAndParameterToNonEmptyOnUpdateWithParameterAndComplimentoryField() {
        
        let fieldElement = AnywayPayment.Element.field(makeAnywayPaymentField())
        let parameterElement = AnywayPayment.Element.parameter(makeAnywayPaymentParameter())
        let payment = makeAnywayPayment(elements: [fieldElement, parameterElement])
        let updateField = makeAnywayPaymentUpdateField("a", value: "aa", title: "aaa")
        let updateParameter = makeAnywayPaymentUpdateParameter()
        let update = makeAnywayPaymentUpdate(
            fields: [updateField],
            parameters: [updateParameter]
        )
        
        assert(payment, on: update) {
            
            $0.elements = [fieldElement, parameterElement]
            + [updateField.field].map(AnywayPayment.Element.field)
            + [updateParameter.parameter].map(AnywayPayment.Element.parameter)
        }
    }
    
    func test_update_shouldAppendElementsToNonEmptyOnUpdateWithParametersAndComplimentoryFields() {
        
        let fieldElement = AnywayPayment.Element.field(makeAnywayPaymentField())
        let parameterElement = AnywayPayment.Element.parameter(makeAnywayPaymentParameter())
        let payment = makeAnywayPayment(elements: [fieldElement, parameterElement])
        let updateField1 = makeAnywayPaymentUpdateField("a", value: "aa", title: "aaa")
        let updateField2 = makeAnywayPaymentUpdateField("1", value: "11", title: "111")
        let updateParameter1 = makeAnywayPaymentUpdateParameter()
        let updateParameter2 = makeAnywayPaymentUpdateParameter()
        let update = makeAnywayPaymentUpdate(
            fields: [updateField1, updateField2],
            parameters: [updateParameter1, updateParameter2]
        )
        
        assert(payment, on: update) {
            
            let complimentaryFields = [updateField1, updateField2].map(\.field)
            let parameters = [updateParameter1, updateParameter2].map(\.parameter)
            $0.elements = [fieldElement, parameterElement]
            + complimentaryFields.map(AnywayPayment.Element.field)
            + parameters.map(AnywayPayment.Element.parameter)
        }
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
    precedes fields: [AnywayPaymentUpdate.Field],
    file: StaticString = #file,
    line: UInt = #line
) {
    XCTAssert(
        hasOTPField(payment),
        "Expected OTP field in payment fields.",
        file: file, line: line
    )
    
    let fields = fields.map(\.field)
    
#warning("this check is for fields only - is it ok or it needs to check all element cases?")
    XCTAssert(
        payment.paymentFields.isElementAfterAll(.otp, inGroup: fields),
        "Expected OTP field after complimentary fields.",
        file: file, line: line
    )
}

private extension AnywayPaymentUpdate.Field {
    
    var field: AnywayPayment.Element.Field {
        
        .init(
            id: .string(name),
            value: value,
            title: title
        )
    }
}

private extension AnywayPaymentUpdate.Parameter {
    
    var parameter: AnywayPayment.Element.Parameter {
        
        .init()
    }
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
    _ id: AnywayPayment.Element.Field.ID = .string(UUID().uuidString),
    value: String = UUID().uuidString,
    title: String = UUID().uuidString
) -> AnywayPayment.Element.Field {
    
    .init(id: id, value: value, title: title)
}

private func makeAnywayPaymentFieldWithStringID(
    _ id: String = UUID().uuidString,
    value: String = UUID().uuidString,
    title: String = UUID().uuidString
) -> AnywayPayment.Element.Field {
    
    makeAnywayPaymentField(.string(id), value: value, title: title)
}

private func makeAnywayPaymentParameter(
) -> AnywayPayment.Element.Parameter {
    
    .init()
}

private func makeOTPField(
    value: String = UUID().uuidString,
    title: String = UUID().uuidString
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
    _ name: String = UUID().uuidString,
    value: String = UUID().uuidString,
    title: String = UUID().uuidString
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
