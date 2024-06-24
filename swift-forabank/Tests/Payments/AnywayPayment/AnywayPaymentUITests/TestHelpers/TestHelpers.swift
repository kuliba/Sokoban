//
//  File.swift
//
//
//  Created by Igor Malyarov on 16.06.2024.
//

import AnywayPaymentCore
import AnywayPaymentDomain
import AnywayPaymentUI
import Foundation

typealias AnywayTransaction = AnywayTransactionState<DocumentStatus, Response>
typealias DocumentStatus = Int
typealias Response = String

func isEmpty(
    _ transaction: AnywayTransaction
) -> Bool {
    
    return transaction.context.payment.elements.isEmpty
}

func makeTransaction(
    context: AnywayPaymentContext = makeAnywayPaymentContext(),
    isValid: Bool = true,
    status: Status<DocumentStatus, Response>? = nil
) -> AnywayTransaction {
    
    return .init(
        context: context,
        isValid: isValid,
        status: status
    )
}

func makeTransaction(
    elements: [AnywayElement],
    footer: Payment<AnywayElement>.Footer = .continue,
    isValid: Bool = true,
    status: Status<DocumentStatus, Response>? = nil
) -> AnywayTransaction {
    
    return .init(
        context: makeAnywayPaymentContext(
            payment: makeAnywayPayment(
                elements: elements,
                footer: footer
            )
        ),
        isValid: isValid,
        status: status
    )
}

func makeTransactionWithAmount(
    elements: [AnywayElement] = [],
    amount: Decimal,
    isValid: Bool = true,
    status: Status<DocumentStatus, Response>? = nil
) -> AnywayTransaction {
    
    return .init(
        context: makeAnywayPaymentContext(
            payment: makeAnywayPayment(
                elements: elements,
                footer: .amount(amount)
            )
        ),
        isValid: isValid,
        status: status
    )
}

func makeTransactionWithContinue(
    elements: [AnywayElement] = [],
    isValid: Bool = true,
    status: Status<DocumentStatus, Response>? = nil
) -> AnywayTransaction {
    
    return .init(
        context: makeAnywayPaymentContext(
            payment: makeAnywayPayment(
                elements: elements,
                footer: .continue
            )
        ),
        isValid: isValid,
        status: status
    )
}

func makeAnywayPaymentContext(
    initial: AnywayPayment = makeAnywayPayment(),
    payment: AnywayPayment = makeAnywayPayment(),
    staged: AnywayPaymentStaged = [],
    outline: AnywayPaymentOutline = makeAnywayPaymentOutline(),
    shouldRestart: Bool = false
) -> AnywayPaymentContext {
    
    return .init(
        initial: initial,
        payment: payment,
        staged: staged,
        outline: outline,
        shouldRestart: shouldRestart
    )
}

func makeAnywayPayment(
    elements: [AnywayElement] = [],
    footer: Payment<AnywayElement>.Footer = .continue,
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

func makeAnywayPaymentDigest(
    additional: [AnywayPaymentDigest.Additional] = [],
    amount: Decimal? = nil,
    core: AnywayPaymentDigest.PaymentCore? = nil,
    puref: AnywayPaymentDigest.Puref = anyMessage()
) -> AnywayPaymentDigest {
    
    return .init(
        additional: additional,
        amount: amount,
        core: core,
        puref: puref
    )
}

func makeFieldAnywayElement(
    _ field: AnywayElement.Field = makeAnywayElementField()
) -> AnywayElement {
    
    return .field(field)
}

func makeFieldAnywayElement(
    id: AnywayElement.Field.ID
) -> AnywayElement {
    
    return makeFieldAnywayElement(
        makeAnywayElementField(id: id)
    )
}

func makeAnywayElementField(
    id: AnywayElement.Field.ID = anyMessage(),
    title: String = anyMessage(),
    value: AnywayElement.Field.Value = anyMessage(),
    image: AnywayElement.Image? = nil
) -> AnywayElement.Field {
    
    return .init(id: id, title: title, value: value, image: image)
}

func makeParameterAnywayElement(
    _ parameter: AnywayElement.Parameter = makeAnywayElementParameter()
) -> AnywayElement {
    
    return .parameter(parameter)
}

func makeAnywayElementParameter(
    field: AnywayElement.Parameter.Field = makeAnywayElementParameterField(),
    image: AnywayElement.Image? = nil,
    masking: AnywayElement.Parameter.Masking = makeAnywayElementParameterMasking(),
    validation: AnywayElement.Parameter.Validation = makeAnywayElementParameterValidation(),
    uiAttributes: AnywayElement.Parameter.UIAttributes = makeAnywayElementParameterUIAttributes()
) -> AnywayElement.Parameter {
    
    return .init(
        field: field,
        image: image,
        masking: masking,
        validation: validation,
        uiAttributes: uiAttributes
    )
}

func makeAnywayElementParameterField(
    id: AnywayElement.Parameter.Field.ID = anyMessage(),
    value: AnywayElement.Parameter.Field.Value? = anyMessage()
) -> AnywayElement.Parameter.Field {
    
    return .init(id: id, value: value)
}

func makeAnywayElementParameterMasking(
    inputMask: String? = nil,
    mask: String? = nil
) -> AnywayElement.Parameter.Masking {
    
    return .init(inputMask: inputMask, mask: mask)
}

func makeAnywayElementParameterValidation(
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

func makeAnywayElementParameterUIAttributes(
    dataType: AnywayElement.Parameter.UIAttributes.DataType = .string,
    group: String? = nil,
    isPrint: Bool = false,
    phoneBook: Bool = false,
    isReadOnly: Bool = false,
    subGroup: String? = nil,
    subTitle: String? = nil,
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

func makeAnywayPaymentOutline(
    core: AnywayPaymentOutline.PaymentCore = makePaymentCore(),
    fields: AnywayPaymentOutline.Fields = [:],
    payload: AnywayPaymentOutline.Payload = makeOutlinePayload()
) -> AnywayPaymentOutline {
    
    return .init(
        core: core,
        fields: fields,
        payload: payload
    )
}

func makePaymentCore(
    amount: Decimal = anyAmount(),
    currency: String = "RUB",
    productID: Int = anyProductID(),
    productType: AnywayPaymentOutline.PaymentCore.ProductType = .account
) -> AnywayPaymentOutline.PaymentCore {
    
    return .init(
        amount: amount,
        currency: currency,
        productID: productID,
        productType: productType
    )
}

func anyAmount(
    _ value: Double = .random(in: 1...1_000)
) -> Decimal {
    
    return .init(value)
}

func anyProductID(
    _ value: Int = .random(in: 1...1_000)
) -> Int {
    
    return value
}

func makeOutlinePayload(
    puref: AnywayPaymentOutline.Payload.Puref = anyMessage(),
    title: String = anyMessage(),
    subtitle: String? = anyMessage(),
    icon: String? = anyMessage()
) -> AnywayPaymentOutline.Payload {
    
    return .init(
        puref: puref,
        title: title,
        subtitle: subtitle,
        icon: icon
    )
}
