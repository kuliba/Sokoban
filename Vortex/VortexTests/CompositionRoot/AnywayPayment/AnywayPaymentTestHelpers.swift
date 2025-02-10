//
//  AnywayPaymentTestHelpers.swift
//  VortexTests
//
//  Created by Igor Malyarov on 11.08.2024.
//

import AnywayPaymentCore
import AnywayPaymentDomain
import Foundation
import RemoteServices
@testable import Vortex

func makeCreateAnywayTransferResponse(
    finalStep: Bool = false,
    needMake: Bool = false
) -> RemoteServices.ResponseMapper.CreateAnywayTransferResponse {
    
    return .init(additional: [], finalStep: finalStep, needMake: needMake, needOTP: false, needSum: false, parametersForNextStep: [], options: [])
}

private func makeTransaction(
    context: AnywayPaymentContext = makeAnywayPaymentContext(),
    isValid: Bool = true
) -> AnywayTransactionState.Transaction {
    
    return .init(context: context, isValid: isValid)
}

private func makeAnywayPaymentContext(
    initial: AnywayPaymentDomain.AnywayPayment = makeAnywayPayment(),
    payment: AnywayPaymentDomain.AnywayPayment = makeAnywayPayment(),
    staged: AnywayPaymentStaged = .init(),
    outline: AnywayPaymentOutline = makeAnywayPaymentOutline(),
    shouldRestart: Bool = false,
    needSum: Bool = false
) -> AnywayPaymentContext {
    
    return .init(
        initial: initial,
        payment: payment,
        staged: staged,
        outline: outline,
        shouldRestart: shouldRestart,
        needSum: needSum
    )
}

private func makeAnywayPayment(
    amount: Decimal? = nil,
    elements: [AnywayElement] = [],
    footer: Payment<AnywayElement>.Footer = .continue,
    isFinalStep: Bool = false
) -> AnywayPaymentDomain.AnywayPayment {
    
    return .init(amount: amount, elements: elements, footer: footer, isFinalStep: isFinalStep)
}

func makeAnywayPaymentOutline(
    amount: Decimal? = nil,
    product: AnywayPaymentOutline.Product = makeOutlineProduct(),
    fields: AnywayPaymentOutline.Fields = .init(),
    payload: AnywayPaymentOutline.Payload = makeOutlinePayload()
) -> AnywayPaymentOutline {
    
    return .init(amount: amount, product: product, fields: fields, payload: payload)
}

func makeOutlineProduct(
    currency: String = anyMessage(),
    productID: Int = .random(in: 1...100),
    productType: AnywayPaymentOutline.Product.ProductType = .card
) -> AnywayPaymentOutline.Product {
    
    return .init(currency: currency, productID: productID, productType: productType)
}

private func makeOutlinePayload(
    puref: AnywayPaymentOutline.Payload.Puref = makeOutlinePayloadPuref(),
    title: String = anyMessage(),
    subtitle: String? = nil,
    icon: String? = nil,
    templateID: Int? = nil
) -> AnywayPaymentOutline.Payload {
    
    return .init(puref: puref, title: title, subtitle: subtitle, icon: icon, templateID: templateID)
}

private func makeOutlinePayloadPuref(
    _ value: String = anyMessage()
) -> AnywayPaymentOutline.Payload.Puref {
    
    return value
}
