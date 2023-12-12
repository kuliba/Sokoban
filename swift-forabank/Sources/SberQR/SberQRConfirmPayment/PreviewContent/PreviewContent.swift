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
        brandName: .preview(.brandName),
        recipientBank: .preview(.recipientBank),
        currency: .preview,
        bottom: .preview
    )
}

extension SberQRConfirmPaymentState.FixedAmount {
    
    static let preview: Self = .init(
        header: .preview,
        productSelect: .preview,
        brandName: .preview(.brandName),
        amount: .preview(.amount),
        recipientBank: .preview(.recipientBank),
        bottom: .preview
    )
}

extension ProductSelect {
    
    static let preview: Self = .compact(.cardPreview)
}

extension Array where Element == ProductSelect.Product {
    
    static let allProducts: Self = [
        .accountPreview,
        .account2Preview,
        .cardPreview,
        .card2Preview,
        .card3Preview,
    ]
}

extension ProductSelect.Product {
    
    static let accountPreview: Self = .init(
        id: 234567891,
        type: .account,
        icon: "",
        title: "Account",
        amountFormatted: "",
        color: ""
    )
    
    static let account2Preview: Self = .init(
        id: 2345678912,
        type: .account,
        icon: "",
        title: "Account 2",
        amountFormatted: "",
        color: ""
    )
    
    static let cardPreview: Self = .init(
        id: 123456789,
        type: .card,
        icon: "",
        title: "Card",
        amountFormatted: "",
        color: ""
    )
    
    static let card2Preview: Self = .init(
        id: 1234567892,
        type: .card,
        icon: "",
        title: "Card 2",
        amountFormatted: "",
        color: ""
    )
    
    static let card3Preview: Self = .init(
        id: 1234567893,
        type: .card,
        icon: "",
        title: "Card 3",
        amountFormatted: "",
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

extension SberQRConfirmPaymentState.Info {
    
    static func preview(
        _ id: SberQRConfirmPaymentState.Info.ID
    ) -> Self {
        
        .init(
            id: id,
            value: "",
            title: "",
            icon: .init(
                type: .local,
                value: ""
            )
        )
    }
}
