//
//  AnywayPaymentTestsHelpers.swift
//
//
//  Created by Igor Malyarov on 06.04.2024.
//

import AnywayPaymentCore
import AnywayPaymentDomain
import Foundation
import XCTest

func assertOTPisLast(
    in payment: AnywayPayment,
    with value: Int? = nil,
    file: StaticString = #file,
    line: UInt = #line
) {
    XCTAssertNoDiff(
        payment.elements.last,
        .widget(makeOTPWidget(value)),
        "Expected OTP field after complimentary fields.",
        file: file, line: line
    )
}

func hasAmountFooter(
    _ payment: AnywayPayment
) -> Bool {
    
    guard case .amount = payment.footer else { return false }
    
    return true
}

func hasContinueFooter(
    _ payment: AnywayPayment
) -> Bool {
    
    guard case .continue = payment.footer else { return false }
    
    return true
}

func hasProductWidget(
    _ payment: AnywayPayment
) -> Bool {
    
    payment.elements.compactMap(\.widget).map(\.id).contains(.product)
}

func hasOTPField(
    _ payment: AnywayPayment
) -> Bool {
    
    payment.elements.compactMap(\.widget).map(\.id).contains(.otp)
}

private extension AnywayElement {
    
    var widget: Widget? {
        
        guard case let .widget(widget) = self else { return nil }
        return widget
    }
}

func isFinalStep(
    _ payment: AnywayPayment
) -> Bool {
    
    payment.isFinalStep
}

func makeAmount(
    _ amount: Decimal = Decimal(generateRandom11DigitNumber())/100
) -> Decimal {
    
    return amount
}

func makeAnywayPaymentContext(
    payment: AnywayPayment = makeAnywayPayment(),
    staged: AnywayPaymentStaged = [],
    outline: AnywayPaymentOutline = makeAnywayPaymentOutline(),
    shouldRestart: Bool = false
) -> AnywayPaymentContext {
    
    return .init(
        payment: payment,
        staged: staged,
        outline: outline,
        shouldRestart: shouldRestart
    )
}

func makeAnywayPayment(
    fields: [AnywayElement.Field],
    isFinalStep: Bool = false,
    core: AnywayElement.Widget.Product? = nil
) -> AnywayPayment {
    
    var elements = fields.map(AnywayElement.field)
    if let core {
        elements.append(.widget(.product(core)))
    }
    
    return makeAnywayPayment(
        elements: elements,
        isFinalStep: isFinalStep
    )
}

func makeAnywayPaymentPayload(
    puref: AnywayPaymentOutline.Payload.Puref = anyMessage(),
    title: String = anyMessage(),
    subtitle: String = anyMessage(),
    icon: String = anyMessage()
) -> AnywayPaymentOutline.Payload {
    
    return .init(puref: puref, title: title, subtitle: subtitle, icon: icon)
}

func makeAnywayPayment(
    parameters: [AnywayElement.Parameter],
    footer: AnywayPayment.Footer = .continue,
    isFinalStep: Bool = false,
    product: AnywayElement.Widget.Product? = nil
) -> AnywayPayment {
    
    var elements = parameters.map(AnywayElement.parameter)
    if let product {
        elements.append(.widget(.product(product)))
    }
    
    return makeAnywayPayment(
        elements: elements,
        footer: footer,
        isFinalStep: isFinalStep
    )
}

func makeAnywayPayment(
    elements: [AnywayElement] = [],
    footer: AnywayPayment.Footer = .continue,
    infoMessage: String? = nil,
    isFinalStep: Bool = false
) -> AnywayPayment {
    
    return .init(
        elements: elements,
        footer: footer,
        infoMessage: infoMessage,
        isFinalStep: isFinalStep
    )
}

func makeAnywayPaymentOutline(
    _ fields: [String: String] = [:],
    core: AnywayPaymentOutline.PaymentCore = makeOutlinePaymentCore(productType: .account),
    payload: AnywayPaymentOutline.Payload = makeAnywayPaymentPayload()
) -> AnywayPaymentOutline {
    
    return .init(
        core: core,
        fields: fields.reduce(into: [:]) { $0[$1.key] = $1.value },
        payload: payload
    )
}

func makeAnywayPaymentWithAmount(
    elements: [AnywayElement] = [],
    _ amount: Decimal = .init(Double.random(in: 1...1_000)),
    file: StaticString = #file,
    line: UInt = #line
) -> AnywayPayment {
    
    let payment = makeAnywayPayment(
        elements: elements,
        footer: .amount(amount)
    )
    XCTAssert(hasAmountFooter(payment), "Expected amount field.", file: file, line: line)
    return payment
}

func makeAnywayPaymentWithProduct(
    parameters: [AnywayElement.Parameter] = [],
    _ currency: String = anyMessage(),
    _ productID: AnywayElement.Widget.Product.ProductID = generateRandom11DigitNumber(),
    _ productType: AnywayElement.Widget.Product.ProductType = .account,
    file: StaticString = #file,
    line: UInt = #line
) -> AnywayPayment {
    
    let payment = makeAnywayPayment(
        parameters: parameters,
        product: .init(
            currency: currency,
            productID: productID,
            productType: productType
        )
    )
    XCTAssertFalse(currency.isEmpty, "Expected non-empty currency.", file: file, line: line)
    XCTAssert(hasProductWidget(payment), "Expected amount field.", file: file, line: line)
    return payment
}

func makeAnywayPaymentWithoutAmount(
    file: StaticString = #file,
    line: UInt = #line
) -> AnywayPayment {
    
    let payment = makeAnywayPayment()
    XCTAssertFalse(hasAmountFooter(payment), "Expected no amount field.", file: file, line: line)
    return payment
}

func makeAnywayPaymentWithOTP(
    file: StaticString = #file,
    line: UInt = #line
) -> AnywayPayment {
    
    let payment = makeAnywayPayment(elements: [.widget(makeOTPWidget())])
    XCTAssert(hasOTPField(payment), "Expected to have OTP field.", file: file, line: line)
    return payment
}

func makeAnywayPaymentField(
    _ id: AnywayElement.Field.ID = anyMessage(),
    value: String = anyMessage(),
    title: String = anyMessage(),
    image: AnywayElement.Image? = nil
) -> AnywayElement.Field {
    
    return .init(id: id, title: title, value: value, image: image)
}

func makeAnywayPaymentField(
    id: String,
    value: String = anyMessage(),
    title: String = anyMessage()
) -> AnywayElement.Field {
    
    return makeAnywayPaymentField(id, value: value, title: title)
}

func makeAnywayPaymentParameter(
    field: AnywayElement.Parameter.Field = makeAnywayPaymentElementParameterField(),
    image: AnywayElement.Image? = nil,
    masking: AnywayElement.Parameter.Masking = makeAnywayPaymentElementParameterMasking(),
    validation: AnywayElement.Parameter.Validation = makeAnywayPaymentElementParameterValidation(),
    uiAttributes: AnywayElement.Parameter.UIAttributes = makeAnywayPaymentElementParameterUIAttributes()
) -> AnywayElement.Parameter {
    
    return .init(
        field: field,
        image: image,
        masking: masking,
        validation: validation,
        uiAttributes: uiAttributes
    )
}

func makeAnywayPaymentParameter(
    id: String,
    value: String
) -> AnywayElement.Parameter {
    
    return makeAnywayPaymentParameter(
        field: makeAnywayPaymentElementParameterField(id: id, value: value)
    )
}

func makeAnywayPaymentParameter(
    id: String = anyMessage(),
    value: String? = anyMessage(),
    isRequired: Bool
) -> AnywayElement.Parameter {
    
    return makeAnywayPaymentParameter(
        field: makeAnywayPaymentElementParameterField(id: id, value: value),
        validation: .init(
            isRequired: isRequired,
            maxLength: nil,
            minLength: nil,
            regExp: ""
        )
    )
}

func makeAnywayPaymentParameter(
    id: String = anyMessage(),
    value: String? = anyMessage(),
    minLength: Int?
) -> AnywayElement.Parameter {
    
    return makeAnywayPaymentParameter(
        field: makeAnywayPaymentElementParameterField(id: id, value: value),
        validation: .init(
            isRequired: false,
            maxLength: nil,
            minLength: minLength,
            regExp: ""
        )
    )
}

func makeAnywayPaymentParameter(
    id: String = anyMessage(),
    value: String? = anyMessage(),
    maxLength: Int?
) -> AnywayElement.Parameter {
    
    return makeAnywayPaymentParameter(
        field: makeAnywayPaymentElementParameterField(id: id, value: value),
        validation: .init(
            isRequired: false,
            maxLength: maxLength,
            minLength: nil,
            regExp: ""
        )
    )
}

func makeAnywayPaymentParameter(
    id: String = anyMessage(),
    value: String? = anyMessage(),
    regExp: String
) -> AnywayElement.Parameter {
    
    return makeAnywayPaymentParameter(
        field: makeAnywayPaymentElementParameterField(id: id, value: value),
        validation: .init(
            isRequired: false,
            maxLength: nil,
            minLength: nil,
            regExp: regExp
        )
    )
}

func makeAnywayPaymentParameter(
    id: String = anyMessage(),
    value: String? = anyMessage(),
    viewType: AnywayElement.Parameter.UIAttributes.ViewType = .input
) -> AnywayElement.Parameter {
    
    return makeAnywayPaymentParameter(
        field: makeAnywayPaymentElementParameterField(
            id: id,
            value: value
        ),
        uiAttributes: makeAnywayPaymentElementParameterUIAttributes(
            viewType: viewType
        )
    )
}

func makeAnywayPaymentElementParameterField(
    id: String = anyMessage(),
    value: String? = anyMessage()
) -> AnywayElement.Parameter.Field {
    
    return .init(id: id, value: value)
}

private func makeAnywayPaymentElementParameterMasking(
    inputMask: String? = nil,
    mask: String? = nil
) -> AnywayElement.Parameter.Masking {
    
    return .init(inputMask: inputMask, mask: mask)
}

private func makeAnywayPaymentElementParameterValidation(
    isRequired: Bool = true,
    maxLength: Int? = nil,
    minLength: Int? = nil,
    regExp: String = anyMessage()
) -> AnywayElement.Parameter.Validation {
    
    return .init(
        isRequired: isRequired,
        maxLength: maxLength,
        minLength: minLength,
        regExp: regExp
    )
}

func makeAnywayPaymentElementParameterUIAttributes(
    dataType: AnywayElement.Parameter.UIAttributes.DataType = .string,
    group: String? = nil,
    isPrint: Bool = true,
    phoneBook: Bool = false,
    isReadOnly: Bool = false,
    subGroup: String? = nil,
    subTitle: String? = nil,
    svgImage: String? = nil,
    title: String = anyMessage(),
    type: AnywayElement.Parameter.UIAttributes.FieldType = .input,
    viewType: AnywayElement.Parameter.UIAttributes.ViewType = .input
) -> AnywayElement.Parameter.UIAttributes {
    
    return .init(
        dataType: dataType,
        group: group,
        isPrint: isPrint,
        phoneBook: phoneBook,
        isReadOnly: isReadOnly,
        subGroup: subGroup,
        subTitle: subTitle,
        title: title,
        type: type,
        viewType: viewType
    )
}

func makeAnywayPaymentFieldElement(
    _ field: AnywayElement.Field = makeAnywayPaymentField()
) -> AnywayElement {
    
    return .field(field)
}

func makeAnywayPaymentParameterElement(
    _ parameter: AnywayElement.Parameter = makeAnywayPaymentParameter()
) -> AnywayElement {
    
    return .parameter(parameter)
}

func makeAnywayPaymentWidgetElement(
    _ widget: AnywayElement.Widget
) -> AnywayElement {
    
    return .widget(widget)
}

func makeOTPWidget(
    _ value: Int? = nil
) -> AnywayElement.Widget {
    
    return .otp(value)
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
    needSum: Bool = false,
    isMultiSum: Bool = false
) -> AnywayPaymentUpdate {
    
    return makeAnywayPaymentUpdate(
        details: makeAnywayPaymentUpdateDetails(
            control: makeAnywayPaymentUpdateDetailsControl(
                isFinalStep: isFinalStep,
                isFraudSuspected: isFraudSuspected,
                isMultiSum: isMultiSum,
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
    
    return .init(
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
    
    return .init(
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

private func makeAnywayPaymentUpdateDetailsControl(
    isFinalStep: Bool = false,
    isFraudSuspected: Bool = false,
    isMultiSum: Bool = false,
    needMake: Bool = false,
    needOTP: Bool = false,
    needSum: Bool = false
) -> AnywayPaymentUpdate.Details.Control {
    
    return .init(
        isFinalStep: isFinalStep,
        isFraudSuspected: isFraudSuspected,
        isMultiSum: isMultiSum,
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
    
    return .init(
        documentStatus: documentStatus,
        infoMessage: infoMessage,
        payeeName: payeeName,
        paymentOperationDetailID: paymentOperationDetailID,
        printFormType: printFormType
    )
}

func makeAnywayPaymentUpdateField(
    _ name: String = anyMessage(),
    title: String = anyMessage(),
    value: String = anyMessage(),
    image: AnywayPaymentUpdate.Image? = nil
) -> AnywayPaymentUpdate.Field {
    
    return .init(name: name, value: value, title: title, image: image)
}

func makeAnywayPaymentAndUpdateFields(
    _ name: String = anyMessage(),
    value: String = anyMessage(),
    title: String = anyMessage()
) -> (update: AnywayPaymentUpdate.Field, updated: AnywayElement.Field) {
    
    let update = makeAnywayPaymentUpdateField(
        name,
        title: title,
        value: value
    )
    
    let updated = makeAnywayPaymentField(
        .init(name),
        value: value,
        title: title
    )
    
    return (update, updated)
}

func makeAnywayPaymentUpdateParameter(
    field: AnywayPaymentUpdate.Parameter.Field = makeAnywayPaymentUpdateParameterField(),
    image: AnywayPaymentUpdate.Image? = nil,
    masking: AnywayPaymentUpdate.Parameter.Masking = makeAnywayPaymentUpdateParameterMasking(),
    validation: AnywayPaymentUpdate.Parameter.Validation = makeAnywayPaymentUpdateParameterValidation(),
    uiAttributes: AnywayPaymentUpdate.Parameter.UIAttributes = makeAnywayPaymentUpdateParameterUIAttributes()
) -> AnywayPaymentUpdate.Parameter {
    
    return .init(
        field: field,
        image: image,
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
    title: String = anyMessage(),
    type: AnywayPaymentUpdate.Parameter.UIAttributes.FieldType = .input,
    viewType: AnywayPaymentUpdate.Parameter.UIAttributes.ViewType = .input
    
) -> (update: AnywayPaymentUpdate.Parameter, updated: AnywayElement.Parameter) {
    
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
) -> (update: AnywayPaymentUpdate.Parameter.Field, updated: AnywayElement.Parameter.Field) {
    
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
) -> (update: AnywayPaymentUpdate.Parameter.Masking, updated: AnywayElement.Parameter.Masking) {
    
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
) -> (update: AnywayPaymentUpdate.Parameter.Validation, updated: AnywayElement.Parameter.Validation) {
    
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
    title: String = anyMessage(),
    type: AnywayPaymentUpdate.Parameter.UIAttributes.FieldType = .input,
    viewType: AnywayPaymentUpdate.Parameter.UIAttributes.ViewType = .input
) -> (update: AnywayPaymentUpdate.Parameter.UIAttributes, updated: AnywayElement.Parameter.UIAttributes) {
    
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
        title: title,
        type: .init(with: type),
        viewType: .init(with: viewType)
    )
    
    return (update, updated)
}

private extension AnywayElement.Parameter.UIAttributes.DataType {
    
    init(with dataType: AnywayPaymentUpdate.Parameter.UIAttributes.DataType) {
        
        switch dataType {
        case ._backendReserved:
            self = ._backendReserved
            
        case .number:
            self = .number
            
        case let .pairs(pair, pairs):
            self = .pairs(pair.pair, pairs.map(\.pair))
            
        case .string:
            self = .string
        }
    }
}

private extension AnywayPaymentUpdate.Parameter.UIAttributes.DataType.Pair {
    
    var pair: AnywayElement.Parameter.UIAttributes.DataType.Pair {
        
        .init(key: key, value: value)
    }
}

private extension AnywayElement.Parameter.UIAttributes.FieldType {
    
    init(with fieldType: AnywayPaymentUpdate.Parameter.UIAttributes.FieldType) {
        
        switch fieldType {
        case .input:    self = .input
        case .maskList: self = .maskList
        case .missing:  self = .missing
        case .select:   self = .select
        }
    }
}

private extension AnywayElement.Parameter.UIAttributes.ViewType {
    
    init(with viewType: AnywayPaymentUpdate.Parameter.UIAttributes.ViewType) {
        
        switch viewType {
        case .constant: self = .constant
        case .input:    self = .input
        case .output:   self = .output
        }
    }
}

func makeAnywayPaymentUpdateParameterField(
    content: String? = nil,
    dataDictionary: String? = nil,
    dataDictionaryРarent: String? = nil,
    id: String = anyMessage()
) -> AnywayPaymentUpdate.Parameter.Field {
    
    return .init(
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
    
    return .init(inputMask: inputMask, mask: mask)
}

private func makeAnywayPaymentUpdateParameterValidation(
    isRequired: Bool = true,
    maxLength: Int? = nil,
    minLength: Int? = nil,
    rawLength: Int = 0,
    regExp: String = anyMessage()
) -> AnywayPaymentUpdate.Parameter.Validation {
    
    return .init(
        isRequired: isRequired,
        maxLength: maxLength,
        minLength: minLength,
        rawLength: rawLength,
        regExp: regExp
    )
}

func makeAnywayPaymentUpdateParameterUIAttributes(
    dataType: AnywayPaymentUpdate.Parameter.UIAttributes.DataType = .string,
    group: String? = nil,
    inputFieldType: AnywayPaymentUpdate.Parameter.UIAttributes.InputFieldType? = nil,
    isPrint: Bool = true,
    order: Int? = nil,
    phoneBook: Bool = false,
    isReadOnly: Bool = false,
    subGroup: String? = nil,
    subTitle: String? = nil,
    title: String = anyMessage(),
    type: AnywayPaymentUpdate.Parameter.UIAttributes.FieldType = .input,
    viewType: AnywayPaymentUpdate.Parameter.UIAttributes.ViewType = .input
) -> AnywayPaymentUpdate.Parameter.UIAttributes {
    
    return .init(
        dataType: dataType,
        group: group,
        inputFieldType: inputFieldType,
        isPrint: isPrint,
        order: order,
        phoneBook: phoneBook,
        isReadOnly: isReadOnly,
        subGroup: subGroup,
        subTitle: subTitle,
        title: title,
        type: type,
        viewType: viewType
    )
}

func makeIntID(
    _ id: Int = generateRandom11DigitNumber()
) -> Int {
    
    return id
}

func makeOutlinePaymentCore(
    amount: Decimal = makeAmount(),
    currency: String = anyMessage(),
    productID: Int = makeIntID(),
    productType: AnywayPaymentOutline.PaymentCore.ProductType
) -> AnywayPaymentOutline.PaymentCore {
    
    return .init(
        amount: amount,
        currency: currency,
        productID: productID,
        productType: productType
    )
}

func makeProductWidget(
    currency: String = anyMessage(),
    productID: Int = makeIntID(),
    productType: AnywayElement.Widget.Product.ProductType = .account
) -> AnywayElement.Widget.Product {
    
    return .init(
        currency: currency,
        productID: productID,
        productType: productType
    )
}

func parameters(
    of payment: AnywayPayment
) -> [AnywayElement.Parameter] {
    
    payment.elements.compactMap(\.parameter)
}

private extension AnywayElement {
    
    var parameter: Parameter? {
        
        guard case let .parameter(parameter) = self
        else { return nil }
        
        return parameter
    }
}

extension AnywayElement.Parameter {
    
    func updating(value: String?) -> Self {
        
        return .init(
            field: .init(id: field.id, value: value.map { .init($0) }),
            image: image,
            masking: masking,
            validation: validation,
            uiAttributes: uiAttributes
        )
    }
}

extension AnywayPaymentContext {
    
    func updating(payment: AnywayPayment) -> Self {
        
        return .init(
            payment: payment,
            staged: staged,
            outline: outline,
            shouldRestart: shouldRestart
        )
    }
}

extension AnywayPayment {
    
    func updating(elements: [AnywayElement]) -> Self {
        
        return .init(
            elements: elements,
            footer: footer,
            infoMessage: infoMessage,
            isFinalStep: isFinalStep
        )
    }
}
