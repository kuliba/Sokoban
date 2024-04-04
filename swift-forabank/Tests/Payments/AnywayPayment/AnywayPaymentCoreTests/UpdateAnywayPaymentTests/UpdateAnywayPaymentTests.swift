//
//  UpdateAnywayPaymentTests.swift
//
//
//  Created by Igor Malyarov on 04.04.2024.
//

import AnywayPaymentCore
import XCTest

struct AnywayPayment: Equatable {
    
    var fields: [Field]
    let hasAmount: Bool
    let isFinalStep: Bool
    let isFraudSuspected: Bool
    var status: Status?
}

extension AnywayPayment {
    
    struct Field: Identifiable, Equatable {
        
        let id: ID
        let value: String
        let title: String
    }
    
    enum Status: Equatable {
        
        case infoMessage(String)
    }
}

extension AnywayPayment.Field {
    
    enum ID: Hashable {
        
        case otp
        case string(String)
    }
}

extension AnywayPayment {
    
    func update(with update: AnywayPaymentUpdate) -> Self {
        
        let status = update.details.info.infoMessage.map {
            
            AnywayPayment.Status.infoMessage($0)
        }
        
        var fields: [Field] = update.fields.map { .init($0) }
        
        if update.details.control.needOTP {
            
            fields.append(.init(id: .otp, value: "", title: ""))
        }
        
        return .init(
            fields: fields,
            hasAmount: update.details.control.needSum,
            isFinalStep: update.details.control.isFinalStep,
            isFraudSuspected: update.details.control.isFraudSuspected,
            status: status
        )
    }
}

private extension AnywayPayment.Field {
    
    init(_ field: AnywayPaymentUpdate.Field) {
        
        self.init(
            id: .string(field.fieldName),
            value: field.fieldValue,
            title: field.fieldTitle
        )
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
        let emptyComplementaryFields = [ComplementaryField]()
        let update = makeAnywayPaymentUpdate(
            complementaryFields: emptyComplementaryFields,
            needOTP: true
        )
        
        let updated = payment.update(with: update)
        
        assertOTP(in: updated, precedes: emptyComplementaryFields)
    }
    
    func test_update_shouldAppendOTPFieldAfterComplementaryFieldsOnNeedOTPTrue() {
        
        let payment = makeAnywayPaymentWithoutOTP()
        let complementaryFields = makeComplementaryFields()
        let update = makeAnywayPaymentUpdate(
            complementaryFields: complementaryFields,
            needOTP: true
        )
        
        let updated = payment.update(with: update)
        
        assertOTP(in: updated, precedes: complementaryFields)
    }
    
    // MARK: - complimentary fields
    
    func test_update_shouldAppendComplementaryFieldsAsInfo() {
        
        let complementaryFields = [
            makeComplementaryField("a", value: "aa", title: "aaa"),
            makeComplementaryField("b", value: "bb", title: "bbb"),
            makeComplementaryField("c", value: "cc", title: "ccc")
        ]
        let update = makeAnywayPaymentUpdate(
            complementaryFields: complementaryFields
        )
        
        assert(makeAnywayPayment(), on: update) {
            
            $0.fields = [
                .init(id: .string("a"), value: "aa", title: "aaa"),
                .init(id: .string("b"), value: "bb", title: "bbb"),
                .init(id: .string("c"), value: "cc", title: "ccc"),
            ]
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

private struct ComplementaryField: Identifiable {
    
    let id: String
    let value: String
    let title: String
    
    var field: AnywayPayment.Field {
        
        .init(id: .string(id), value: value, title: title)
    }
    
    var updateField: AnywayPaymentUpdate.Field {
        
        makeAnywayPaymentUpdateField(self)
    }
}

private func assertOTP(
    in payment: AnywayPayment,
    precedes complementaryFields: [ComplementaryField],
    file: StaticString = #file,
    line: UInt = #line
) {
    XCTAssert(
        hasOTPField(payment),
        "Expected OTP field in payment fields.",
        file: file, line: line
    )
    
    let fields = complementaryFields.map(\.field)
    
    XCTAssert(
        payment.fields.isElementAfterAll(.otp, inGroup: fields),
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
    
    payment.fields.map(\.id).contains(.otp)
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
    fields: [AnywayPayment.Field] = [],
    isFinalStep: Bool = false,
    isFraudSuspected: Bool = false,
    hasAmount: Bool = false
) -> AnywayPayment {
    
    .init(
        fields: fields,
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

private func makeOTPField(
    value: String = UUID().uuidString,
    title: String = UUID().uuidString
) -> AnywayPayment.Field {
    
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

private func makeComplementaryField(
    _ idString: String = UUID().uuidString,
    value: String = UUID().uuidString,
    title: String = UUID().uuidString
) -> ComplementaryField {
    
    .init(id: idString, value: value, title: title)
}

private func makeComplementaryFields(
    _ ids: [String] = [UUID().uuidString],
    file: StaticString = #file,
    line: UInt = #line
) -> [ComplementaryField] {
    
    let fields = ids.map { _ in makeComplementaryField() }
    
    XCTAssertFalse(fields.isEmpty, "Expected non-empty array of ComplementaryFields", file: file, line: line)
    return fields
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
    complementaryFields: [ComplementaryField] = [],
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
        fields: complementaryFields.map(\.updateField)
    )
}

private func makeAnywayPaymentUpdateField(
    _ field: ComplementaryField
) -> AnywayPaymentUpdate.Field {
    
    .init(
        fieldName: field.id,
        fieldValue: field.value,
        fieldTitle: field.title,
        recycle: false,
        svgImage: nil,
        typeIdParameterList: nil
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
