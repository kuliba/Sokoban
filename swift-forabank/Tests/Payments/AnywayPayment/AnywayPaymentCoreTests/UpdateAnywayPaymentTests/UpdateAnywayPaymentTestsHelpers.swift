//
//  UpdateAnywayPaymentTestsHelpers.swift
//
//
//  Created by Igor Malyarov on 06.04.2024.
//

import AnywayPaymentCore
import Foundation
import XCTest

func assertOTP(
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

func hasAmountField(
    _ payment: AnywayPayment
) -> Bool {
    
    payment.hasAmount
}

func hasOTPField(
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

func isFinalStep(
    _ payment: AnywayPayment
) -> Bool {
    
    payment.isFinalStep
}

func isFraudSuspected(
    _ payment: AnywayPayment
) -> Bool {
    
    payment.isFraudSuspected
}

func makeAnywayPayment(
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

func makeAnywayPayment(
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

func makeAnywayPayment(
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

func makeAnywayPaymentWithAmount(
    file: StaticString = #file,
    line: UInt = #line
) -> AnywayPayment {
    
    let payment = makeAnywayPayment(hasAmount: true)
    XCTAssert(hasAmountField(payment), "Expected amount field.", file: file, line: line)
    return payment
}

func makeAnywayPaymentWithoutAmount(
    file: StaticString = #file,
    line: UInt = #line
) -> AnywayPayment {
    
    let payment = makeAnywayPayment()
    XCTAssertFalse(hasAmountField(payment), "Expected no amount field.", file: file, line: line)
    return payment
}

func makeAnywayPaymentWithFraudSuspected(
    file: StaticString = #file,
    line: UInt = #line
) -> AnywayPayment {
    
    let payment = makeAnywayPayment(isFraudSuspected: true)
    XCTAssert(isFraudSuspected(payment), "Expected fraud suspected payment.", file: file, line: line)
    return payment
}

func makeAnywayPaymentWithoutFraudSuspected(
    file: StaticString = #file,
    line: UInt = #line
) -> AnywayPayment {
    
    let payment = makeAnywayPayment()
    XCTAssertFalse(isFraudSuspected(payment), "Expected pyament without fraud suspected.", file: file, line: line)
    return payment
}

func makeAnywayPaymentWithOTP(
    file: StaticString = #file,
    line: UInt = #line
) -> AnywayPayment {
    
    let payment = makeAnywayPayment(fields: [makeOTPField()])
    XCTAssert(hasOTPField(payment), "Expected to have OTP field.", file: file, line: line)
    return payment
}

func makeAnywayPaymentField(
    _ id: AnywayPayment.Element.Field.ID = .string(anyMessage()),
    value: String = anyMessage(),
    title: String = anyMessage()
) -> AnywayPayment.Element.Field {
    
    .init(id: id, value: value, title: title)
}

func makeAnywayPaymentFieldWithStringID(
    _ id: String = anyMessage(),
    value: String = anyMessage(),
    title: String = anyMessage()
) -> AnywayPayment.Element.Field {
    
    makeAnywayPaymentField(.string(id), value: value, title: title)
}

func makeAnywayPaymentParameter(
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

func makeAnywayPaymentParameterWithID(
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

func makeAnywayPaymentWithoutOTP(
    file: StaticString = #file,
    line: UInt = #line
) -> AnywayPayment {
    
    let payment = makeAnywayPayment()
    XCTAssertFalse(hasOTPField(payment), "Expected no OTP field.", file: file, line: line)
    return payment
}

func makeFinalStepAnywayPayment(
    file: StaticString = #file,
    line: UInt = #line
) -> AnywayPayment {
    
    let payment = makeAnywayPayment(isFinalStep: true)
    XCTAssert(isFinalStep(payment), "Expected non final step payment.", file: file, line: line)
    return payment
}

func makeNonFinalStepAnywayPayment(
    file: StaticString = #file,
    line: UInt = #line
) -> AnywayPayment {
    
    let payment = makeAnywayPayment(isFinalStep: false)
    XCTAssert(!isFinalStep(payment), "Expected non final step payment.", file: file, line: line)
    return payment
}

func makeAnywayPaymentUpdate(
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

func makeAnywayPaymentUpdate(
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

func makeAnywayPaymentUpdateField(
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

func makeAnywayPaymentAndUpdateFields(
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

func makeAnywayPaymentAndUpdateParameters(
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

extension AnywayPayment.Element.Parameter {
    
    func updating(value: String?) -> Self {
        
        .init(
            field: .init(id: field.id, value: value),
            masking: masking,
            validation: validation,
            uiAttributes: uiAttributes
        )
    }
}
