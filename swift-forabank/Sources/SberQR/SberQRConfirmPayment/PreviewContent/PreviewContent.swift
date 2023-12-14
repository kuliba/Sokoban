//
//  PreviewContent.swift
//  
//
//  Created by Igor Malyarov on 08.12.2023.
//

public extension SberQRConfirmPaymentState.EditableAmount {
    
    static let preview: Self = .init(
        header: .preview,
        productSelect: .preview,
        brandName: .brandName,
        recipientBank: .recipientBank,
        currency: .preview,
        bottom: .preview
    )
}

public extension SberQRConfirmPaymentState.FixedAmount {
    
    static let preview: Self = .init(
        header: .preview,
        productSelect: .previewExpanded,
        brandName: .brandName,
        amount: .amount,
        recipientBank: .recipientBank,
        bottom: .preview
    )
}

extension ProductSelect {
    
    static let preview: Self = .compact(.cardPreview)
    static let previewExpanded: Self = .expanded(.accountPreview, .allProducts)
}

public extension Array where Element == ProductSelect.Product {
    
    static let allProducts: Self = [
        .accountPreview,
        .account2Preview,
        .cardPreview,
        .card2Preview,
        .card3Preview,
    ]
}

extension ProductSelect.Product {
    
    public static let accountPreview: Self = .init(
        id: 234567891,
        type: .account,
        icon: "",
        title: "Текущий счет",
        footer: "- 7891",
        amountFormatted: "123 456 ₽",
        color: ""
    )
    
    static let account2Preview: Self = .init(
        id: 2345678912,
        type: .account,
        icon: "",
        title: "Account 2",
        footer: "- 8912",
        amountFormatted: "678.09 ₽",
        color: ""
    )
    
    public static let cardPreview: Self = .init(
        id: 123456789,
        type: .card,
        icon: "",
        title: "Card",
        footer: "- 6789",
        amountFormatted: "1 234.56 ₽",
        color: ""
    )
    
    static let card2Preview: Self = .init(
        id: 1234567892,
        type: .card,
        icon: "",
        title: "Card 2",
        footer: "- 7892",
        amountFormatted: "12 345 ₽",
        color: ""
    )
    
    static let card3Preview: Self = .init(
        id: 1234567893,
        type: .card,
        icon: "",
        title: "Card 3",
        footer: "- 7893",
        amountFormatted: "123 456.78 ₽",
        color: ""
    )
}

extension SberQRConfirmPaymentState.Amount {
    
    static let preview: Self = .init(
        id: .paymentAmount,
        value: 123.45,
        title: "",
        validationRules: [],
        button: .init(
            title: "Pay",
            action: .paySberQR,
            color: .red
        )
    )
}

extension SberQRConfirmPaymentState.Button {
    
    static let preview: Self = .init(
        id: .buttonPay,
        value: "PAY",
        color: .red,
        action: .pay,
        placement: .bottom
    )
}

extension SberQRConfirmPaymentState.DataString {
    
    static let preview: Self = .init(
        id: .currency,
        value: "RUB"
    )
}

extension SberQRConfirmPaymentState.Header {
    
    static let preview: Self = .init(
        id: .title,
        value: "Title"
    )
}
