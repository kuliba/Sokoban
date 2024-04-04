//
//  UpdateAnywayPaymentTests.swift
//
//
//  Created by Igor Malyarov on 04.04.2024.
//

import AnywayPaymentCore
import XCTest

struct AnywayPayment: Equatable {
    
    let hasAmount: Bool
    let hasOTP: Bool
}

extension AnywayPayment {
    
    func update(with update: AnywayPaymentUpdate) -> Self {
        
        .init(
            hasAmount: update.details.control.needSum,
            hasOTP: update.details.control.needOTP
        )
    }
}

final class UpdateAnywayPaymentTests: XCTestCase {
    
    func test_update_shouldNotAddOTPFieldOnNeedOTPFalse() {
        
        assert(
            makeNoOTPAnywayPayment(),
            on: makeAnywayPaymentUpdate(needOTP: false)
        )
    }
    
    func test_update_shouldAddOTPFieldOnNeedOTPTrue() {
        
        let update = makeAnywayPaymentUpdate(needOTP: true)
        let updated = makeNoOTPAnywayPayment().update(with: update)
        
        XCTAssert(hasOTPField(updated))
    }
    
    func test_update_shouldNotAddAmountFieldOnNeedSumFalse() {
        
        assert(
            makeNoAmountAnywayPayment(),
            on: makeAnywayPaymentUpdate(needSum: false)
        )
    }
    
    func test_update_shouldAddAmountFieldOnNeedSumTrue() {
        
        let update = makeAnywayPaymentUpdate(needSum: true)
        let updated = makeNoAmountAnywayPayment().update(with: update)
        
        XCTAssert(hasAmountField(updated))
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

private func hasAmountField(
    _ payment: AnywayPayment
) -> Bool {
    
    payment.hasAmount
}

private func hasOTPField(
    _ payment: AnywayPayment
) -> Bool {
    
    payment.hasOTP
}

private func makeAnywayPayment(
    hasAmount: Bool = false,
    hasOTP: Bool = false
) -> AnywayPayment {
    
    .init(
        hasAmount: hasAmount,
        hasOTP: hasOTP
    )
}

private func makeNoAmountAnywayPayment(
    file: StaticString = #file,
    line: UInt = #line
) -> AnywayPayment {
    
    let payment = makeAnywayPayment()
    XCTAssert(!hasAmountField(payment), "Expected no amount field.", file: file, line: line)
    return payment
}

private func makeNoOTPAnywayPayment(
    file: StaticString = #file,
    line: UInt = #line
) -> AnywayPayment {
    
    let payment = makeAnywayPayment()
    XCTAssert(!hasOTPField(payment), "Expected no OTP field.", file: file, line: line)
    return payment
}

private func makeOTPAnywayPayment(
    file: StaticString = #file,
    line: UInt = #line
) -> AnywayPayment {
    
    let payment = makeAnywayPayment(hasOTP: true)
    XCTAssert(hasOTPField(payment), "Expected to have OTP field.", file: file, line: line)
    return payment
}

private func makeAnywayPaymentUpdate(
    needOTP: Bool = false,
    needSum: Bool = false
) -> AnywayPaymentUpdate {
    
    makeAnywayPaymentUpdate(
        details: makeAnywayPaymentUpdateDetails(
            control: makeAnywayPaymentUpdateDetailsControl(
                needOTP: needOTP,
                needSum: needSum
            )
        )
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
