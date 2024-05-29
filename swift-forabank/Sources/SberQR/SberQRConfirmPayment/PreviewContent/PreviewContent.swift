//
//  PreviewContent.swift
//
//
//  Created by Igor Malyarov on 08.12.2023.
//

import PaymentComponents

extension EditableAmount<PublishingInfo> {
    
    static var preview: Self {
        
        .init(
            header: .preview,
            productSelect: .preview,
            brandName: .brandName,
            recipientBank: .recipientBank,
            currency: .preview,
            amount: .preview
        )
    }
}

extension FixedAmount<PublishingInfo> {
    
    static var preview: Self {
        
        .init(
            header: .preview,
            productSelect: .previewExpanded,
            brandName: .brandName,
            amount: .amount,
            recipientBank: .recipientBank,
            button: .preview
        )
    }
}

public extension EditableAmount<GetSberQRDataResponse.Parameter.Info> {
    
    static var preview: Self {
        
        .init(
            header: .preview,
            productSelect: .preview,
            brandName: .brandName,
            recipientBank: .recipientBank,
            currency: .preview,
            amount: .preview
        )
    }
}

public extension FixedAmount<GetSberQRDataResponse.Parameter.Info> {
    
    static var preview: Self {
        
        .init(
            header: .preview,
            productSelect: .previewExpanded,
            brandName: .brandName,
            amount: .amount,
            recipientBank: .recipientBank,
            button: .preview
        )
    }
}

extension ProductSelect {
    
    static let preview: Self = .init(selected: .cardPreview)
    static let previewExpanded: Self = .init(
        selected: .accountPreview,
        products: .allProducts
    )
}

extension GetSberQRDataResponse.Parameter.Amount {
    
    static let preview: Self = .init(
        id: .paymentAmount,
        value: 123.45,
        title: "Сумма перевода",
        validationRules: [],
        button: .init(
            title: "Оплатить",
            action: .paySberQR,
            color: .red
        )
    )
}

extension GetSberQRDataResponse.Parameter.Button {
    
    static let preview: Self = .init(
        id: .buttonPay,
        value: "Оплатить",
        color: .red,
        action: .pay,
        placement: .bottom
    )
}

extension GetSberQRDataResponse.Parameter.DataString {
    
    static let preview: Self = .init(
        id: .currency,
        value: "RUB"
    )
}

extension Header {
    
    static let preview: Self = .init(
        id: .title,
        value: "Title"
    )
}
